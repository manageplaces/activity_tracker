module ActivityTracker
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :activity_class, :activity_batch_class, :user_class,
                  :idle_time, :lifetime

    def initialize
      @activity_class = 'Activity'
      @activity_batch_class = 'ActivityBatch'
      @user_class = 'User'

      @idle_time = 600
      @lifetime = 3600
    end
  end
end
