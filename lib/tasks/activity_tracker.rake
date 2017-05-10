namespace 'activity_tracker' do
  desc 'Send e-mail notifications'
  task send_notifications: :environment do
    repo = ActivityTracker::NotificationBatchRepository.new

    batches = repo.pending_to_send

    batches.each do |batch|
      sender = ActivityTracker::NotificationBatchSender.new(batch)
      sender.process
    end
  end
end
