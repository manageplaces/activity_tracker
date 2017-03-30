module ActivityTracker
  class Batcher
    def initialize(options, &block)
      @options = options
      @block = block

      options_init
      default_params_init

      @activity_repository = ActivityRepository.new
      @notification_batch_repository = NotificationBatchRepository.new

      @activity_params = []
      @activities = []
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

        @only = ActivityFilter.new(only)
      end

      if @options.include?(:without)
        without = @options.delete(:without)

        @without = ActivityFilter.new(without)
      end

      if @options.include?(:scope_filter)
        scope_filter = @options.delete(:scope_filter)

        @scope_filter = scope_filter.is_a?(Array) ? scope_filter : [scope_filter]
      end

      raise ArgumentError if @only && @without
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
      @activity_params.map! do |activity_params|
        if (@only && !@only.match?(activity_params)) || (@without && @without.match?(activity_params))
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
        end

        @activity_repository.add(activity)
      end
    end
  end
end
