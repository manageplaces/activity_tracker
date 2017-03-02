module ActivityTracker
  class Collector
    def initialize
      @activities = []
    end

    def add(activity)
      @activities << activity
    end

    def activities
      @activities
    end
  end
end
