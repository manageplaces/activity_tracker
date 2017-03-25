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

        @only = only.is_a?(Array) ? only : [only]
      end

      if @options.include?(:without)
        without = @options.delete(:without)

        @without = without.is_a?(Array) ? without : [without]
      end

      raise ArgumentError if @only && @without
    end

    def filter_by_activity_type
      @activity_params = @collector.activities.to_a.reject do |activity_params|
        activity_type = activity_params[:activity_type]

        (@only && !@only.include?(activity_type)) ||
          (@without && @without.include?(activity_type))
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
      level_resolver = NotificationLevelResolver.new(@activities)
      @activities = level_resolver.perform.reject do |activity, receivers|
        receivers.empty? && activity.scope
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
