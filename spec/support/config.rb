ActivityTracker.configure do |c|
  c.activity_class = 'Activity'
  c.notification_batch_class = 'NotificationBatch'
  c.notification_class = 'Notification'
  c.notification_setting_class = 'NotificationSetting'
  c.user_class = 'User'
end
