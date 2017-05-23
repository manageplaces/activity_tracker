require 'sidekiq'

module ActivityTracker
  class NotificationBatchSenderWorker
    include ::Sidekiq::Worker
    def perform(notification_batch_id)
      repository = NotificationBatchRepository.new
      notification_batch = repository.get_by_id(notification_batch_id)

      return unless notification_batch

      sender = NotificationBatchSender.new(notification_batch)
      sender.process
    end

    def self.perform_wrapper(id)
      if ActivityTracker.configuration.send_mails_async
        NotificationBatchSenderWorker.perform_async(id)
      else
        NotificationBatchSenderWorker.new.perform(id)
      end
    end
  end
end
