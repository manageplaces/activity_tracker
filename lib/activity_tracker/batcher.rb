module ActivityTracker
  class Batcher
    def initialize(options, &block)
      @options = options
      @block = block

      options_init
      default_params_init

      @activity_repository = ActivityRepository.new
      @notification_batch_repository = NotificationBatchRepository.new
      @notification_setting_repository = NotificationSettingRepository.new

      @collected_activities = []
    end

    def process
      return false unless @block

      @collector = CollectorRepository.instance.get

      begin
        @block.call

        filter_activities
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

    def filter_activities
      activities = @collector.activities.to_a

      activities.each do |activity_params|
        receivers = activity_params[:receivers]
        activity_params.delete(:receivers)

        type_string = activity_params[:activity_type]
        type_obj = ActivityTypeRepository.instance.get(type_string)

        next if receivers.try(:count).try(:zero?) && !activity_params[:scope]
        next if type_filtered?(type_string)

        activity_params = @options.merge(activity_params)

        if type_obj.skip_sender && activity_params[:sender] && !receivers.try(:count).zero?
          receivers.reject! { |r| r.id == activity_params[:sender].id }
        end

        receivers.reject! do |r|
          level = @notification_setting_repository.get(r, type_string).try(:level)
          level ||= type_obj.level

          level == NotificationLevels::DISABLED
        end

        @collected_activities << [
          @activity_repository.factory(activity_params),
          receivers
        ]
      end
    end

    def default_params_init
      @default_params = @options
    end

    def type_filtered?(activity_type)
      (@only && !@only.include?(activity_type)) ||
        (@without && @without.include?(activity_type))
    end

    def insert_activities
      @collected_activities.each do |activity, receivers|
        type = ActivityTypeRepository.instance.get(activity.activity_type)
        batchable = type.batchable

        receivers.each do |receiver|
          batch = @notification_batch_repository.find_or_create(receiver.id, !batchable)
          @notification_batch_repository.add(batch)
          activity.notifications.build(notification_batch: batch)
        end

        @activity_repository.add(activity)
      end
    end
  end
end
