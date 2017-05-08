module ActivityTracker
  class NotificationBatchSender
    def initialize(notification_batch)
      @notification_batch = notification_batch

      @mailer_lambda = ActivityTracker.configuration.default_mailer
    end

    def process
      return false if @notification_batch.is_sent
      return false if @notification_batch.amendable?

      @notifications = @notification_batch.notifications.select(&:send_mail)

      unless @notifications.count.zero?
        @mailer_lambda.call(@notification_batch.receiver, @notifications)
      end

      set_as_sent

      true
    end

    protected

    def set_as_sent
      return if @notification_batch.is_sent

      @notification_batch.is_sent = true
      @notification_batch.save
    end
  end
end
