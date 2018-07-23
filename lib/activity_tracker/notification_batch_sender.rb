module ActivityTracker
  class NotificationBatchSender
    def initialize(notification_batch)
      @notification_batch = notification_batch
      @activity_type_repository = ActivityTypeRepository.instance

      @default_mailer = ActivityTracker.configuration.default_mailer
    end

    def process
      return false if @notification_batch.is_sent
      return false if @notification_batch.amendable?

      @notifications = @notification_batch.notifications.select(&:send_mail)
      @activities = @notifications.map(&:activity).compact

      unless @activities.count.zero?
        send_mail(@notification_batch.receiver, @activities)
      end

      set_as_sent

      true
    end

    protected

    def send_mail(receiver, activities)
      types = activities.map(&:activity_type).uniq

      if types.count == 1
        activity_type = @activity_type_repository.get(types.first)
        if activity_type.mailer
          return activity_type.mailer.call(receiver, activities)
        end
      end

      @default_mailer.call(receiver, activities)
    end

    def set_as_sent
      return if @notification_batch.is_sent

      @notification_batch.is_sent = true
      @notification_batch.save(validate: false)
    end
  end
end
