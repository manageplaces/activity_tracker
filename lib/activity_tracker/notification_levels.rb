module ActivityTracker
  module NotificationLevels
    DISABLED = 0
    NOTIFICATION_ONLY = 1
    EMAIL = 2

    TYPES = [DISABLED, NOTIFICATION_ONLY, EMAIL].freeze
  end
end
