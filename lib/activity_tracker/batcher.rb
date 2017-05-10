module ActivityTracker
  class Batcher
    def initialize(options, &block)
      @options = options
      @block = block

      options_init
      default_params_init

      @activity_repository = ActivityRepository.new
      @notification_batch_repository = NotificationBatchRepository.new

      @receivers_filter = ActivityTracker.configuration.receivers_filter

      @activity_params = []
      @activities = []

      @unbatchable = []
    end

    def process
      return false unless @block

      @collector = CollectorRepository.instance.get

      begin
        @block.call

        load_from_collector
        filter_by_scope
        filter_by_activity_type
        build_activities
        filter_receivers
        insert_activities

        send_unbatchable
      rescue StandardError => e
        # :nocov:
        raise e
        # :nocov:
      ensure
        CollectorRepository.instance.clear
      end

      true
    end

    protected

    def options_init
      if @options.include?(:only)
        only = @options.delete(:only)

        @activities_only = ActivityFilter.new(only)
      end

      if @options.include?(:without)
        without = @options.delete(:without)

        @activities_without = ActivityFilter.new(without)
      end

      if @options.include?(:notifications)
        notifications_options = @options.delete(:notifications)

        if notifications_options.include?(:only)
          only = notifications_options[:only]

          @notifications_only = ActivityFilter.new(only)
        end

        if notifications_options.include?(:without)
          without = notifications_options[:without]

          @notifications_without = ActivityFilter.new(without)
        end

      end

      if @options.include?(:scope_filter)
        scope_filter = @options.delete(:scope_filter)

        @scope_filter = scope_filter.is_a?(Array) ? scope_filter : [scope_filter]
      end

      raise ArgumentError if @activities_only && @activities_without
      raise ArgumentError if @notifications_only && @notifications_without
    end

    def load_from_collector
      @activity_params = @collector.activities.to_a
    end

    def filter_by_scope
      return unless @scope_filter

      @activity_params.map! do |activity_params|
        unless @scope_filter.include?(activity_params[:scope])
          activity_params[:receivers] = []
          activity_params[:is_hidden] = true
        end

        activity_params
      end
    end

    def filter_by_activity_type
      @activity_params.reject! do |activity_params|
        (@activities_only && !@activities_only.match?(activity_params)) ||
            (@activities_without && @activities_without.match?(activity_params))
      end

      @activity_params.map! do |activity_params|
        if (@notifications_only && !@notifications_only.match?(activity_params)) ||
            (@notifications_without && @notifications_without.match?(activity_params))
          activity_params[:receivers] = []
          activity_params[:is_hidden] = true
        end

        activity_params
      end
    end

    def build_activities
      @activities = @activity_params.map do |activity_params|
        receivers = activity_params[:receivers] || []
        activity_params.delete(:receivers)

        activity_params = @options.merge(activity_params)

        [
          @activity_repository.factory(activity_params),
          receivers
        ]
      end.compact
    end

    def filter_receivers
      @activities.each do |activity, receivers|
        type_string = activity.activity_type
        type_obj = ActivityTypeRepository.instance.get(type_string)

        if @receivers_filter
          receivers.select!(&@receivers_filter)
        end

        if type_obj.skip_sender && activity.sender && !receivers.count.zero?
          receivers.reject! { |r| r.id == activity.sender_id }
        end

        receivers.map! do |receiver|
          level = receiver.notification_level(type_string)

          next if level == ActivityTracker::NotificationLevels::DISABLED

          [receiver, level]
        end.compact!

        [activity, receivers]
      end

      @activities.reject! do |activity, receivers|
        receivers.empty? && !activity.scope
      end
    end

    def default_params_init
      @default_params = @options
    end

    def insert_activities
      @activities.each do |activity, receivers|
        type = ActivityTypeRepository.instance.get(activity.activity_type)
        batchable = type.batchable

        receivers.each do |receiver, level|
          batch = @notification_batch_repository.find_or_create(receiver.id, !batchable)
          @notification_batch_repository.add(batch)
          activity.notifications.build(
            notification_batch: batch,
            send_mail: level == ActivityTracker::NotificationLevels::EMAIL
          )

          @unbatchable << batch unless batchable
        end

        @activity_repository.add(activity)
      end
    end

    def send_unbatchable
      @unbatchable.each do |batch|
        ns = NotificationBatchSender.new(batch)

        ns.process
      end
    end
  end
end
