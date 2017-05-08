namespace 'activity_tracker' do
  desc 'Send e-mail notifications'
  task send_notifications: :environment do
    repo = ActivityTracker::NotificationBatchRepository.new

    mailer_lambda = ActivityTracker.configuration.default_mailer
    batches = repo.pending_to_send

    batches.each do |batch|
      notifications = batch.notifications.select(&:send_mail)

      unless notifications.count.zero?
        mailer_lambda.call(batch.receiver, notifications)
      end

      batch.is_sent = true
      batch.save
    end
  end
end
