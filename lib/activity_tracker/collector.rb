module ActivityTracker
  class Collector
    def initialize
      @activities = []
    end

    def add(params)
      @activities << params
    end

    def activities
      @activities
    end
  end
end
