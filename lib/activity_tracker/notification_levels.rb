module ActivityTracker
  module NotificationLevels
    DISABLED = 0
    NOTIFICATION_ONLY = 1
    EMAIL = 2

    VALUES = {
      DISABLED => 'Disabled',
      NOTIFICATION_ONLY => 'Notification only',
      EMAIL => 'E-mail and notification'
    }.freeze
  end
end
