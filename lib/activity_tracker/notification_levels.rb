module ActivityTracker
  module NotificationLevels
    DISABLED = 0
    NOTIFICATION_ONLY = 1
    EMAIL = 2

    VALUES = {
      DISABLED => 'Disabled',
      NOTIFICATION_ONLY => 'App notification only',
      EMAIL => 'E-mail and App notification'
    }.freeze
  end
end
