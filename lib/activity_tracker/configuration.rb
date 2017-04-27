module ActivityTracker
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :activity_class, :notification_batch_class,
                  :notification_class, :notification_setting_class,
                  :user_class, :idle_time, :lifetime, :default_mailer

    def initialize
      @activity_class = 'Activity'
      @notification_batch_class = 'NotificationBatch'
      @notification_class = 'Notification'
      @user_class = 'User'

      @idle_time = 600
      @lifetime = 3600
    end
  end
end
