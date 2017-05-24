module ActivityTracker
  class Batcher
    def initialize(options, &block)
      @options = options
      @block = block

      options_init

      @activity_repository = ActivityRepository.new
      @notification_batch_repository = NotificationBatchRepository.new

      @receivers_filter = ActivityTracker.configuration.receivers_filter

      @activity_params = []
      @activity_receiver_pairs = []

      @new_batch = false
      @to_close = []
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

        send_closed
      rescue StandardError => e
        # :nocov:
        raise e
        # :nocov:
      ensure
        CollectorRepository.instance.clear
      end

      @activity_receiver_pairs.map { |activity, _receivers| activity }
    end

    protected

    def options_init
      if @options.include?(:only)
        only = @options.delete(:only)

        @activity_receiver_pairs_only = ActivityFilter.new(only)
      end

      if @options.include?(:without)
        without = @options.delete(:without)

        @activity_receiver_pairs_without = ActivityFilter.new(without)
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

      if @options.include?(:close_batches)
        @close_batches = @options.delete(:close_batches)
      end

      raise ArgumentError if @activity_receiver_pairs_only && @activity_receiver_pairs_without
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
        (@activity_receiver_pairs_only && !@activity_receiver_pairs_only.match?(activity_params)) ||
            (@activity_receiver_pairs_without && @activity_receiver_pairs_without.match?(activity_params))
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
      @activity_receiver_pairs = @activity_params.map do |activity_params|
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
      @activity_receiver_pairs.each do |activity, receivers|
        type_string = activity.activity_type
        type_obj = ActivityTypeRepository.instance.get(type_string)

        receivers.compact!
        receivers.select!(&@receivers_filter) if @receivers_filter

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

      @activity_receiver_pairs.reject! do |activity, receivers|
        receivers.empty? && !activity.scope
      end
    end

    def insert_activities
      @activity_receiver_pairs.each do |activity, receivers|
        type = ActivityTypeRepository.instance.get(activity.activity_type)
        batchable = type.batchable

        receivers.each do |receiver, level|
          batch = @notification_batch_repository.find_or_create(receiver.id, !batchable)
          @notification_batch_repository.add(batch)
          activity.notifications.build(
            notification_batch: batch,
            send_mail: level == ActivityTracker::NotificationLevels::EMAIL
          )

          if (!batchable || @close_batches) && !@to_close.include?(batch)
            @to_close << batch
          end
        end

        @activity_repository.add(activity)
      end
    end

    def send_closed
      @to_close.each do |batch|
        unless batch.is_closed?
          batch.is_closed = true
          @notification_batch_repository.add(batch)
        end

        NotificationBatchSenderWorker.perform_wrapper(batch.id)
      end
    end
  end
end
