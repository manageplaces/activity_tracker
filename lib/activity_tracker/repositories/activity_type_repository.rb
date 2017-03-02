module ActivityTracker
  class ActivityTypeRepository
    def initialize
      @activity_types = []
    end

    def add(activity_type)
      @activity_types << activity_type
    end

    def get(activity_type_name)
      @activity_types.find { |t| t.name == activity_type_name }
    end

    def all
      @activity_types
    end

    def self.instance
      @instance ||= ActivityTypeRepository.new
    end
  end
end
