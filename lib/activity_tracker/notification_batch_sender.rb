module ActivityTracker
  class NotificationBatchSender
    def initialize(notification_batch)
      @notification_batch = notification_batch

      @mailer_lambda = ActivityTracker.configuration.default_mailer
    end

    def process
      unless @notification_batch.is_closed && !@notification_batch.is_sent
        return false
      end

      @notifications = @notification_batch.notifications.select(&:send_mail)
      return false if @notifications.count == 0

      @mailer_lambda.call(@notification_batch.receiver, @notifications)

      @notification_batch.is_sent = true
      @notification_batch.save

      true
    end
  end
end
