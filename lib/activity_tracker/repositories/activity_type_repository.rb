module ActivityTracker
  class ActivityTypeRepository
    def add(activity_type = nil)
      raise ArgumentError unless activity_type.is_a?(ActivityType)
      @activity_types << activity_type
    end

    def get(activity_type_name)
      raise ArgumentError unless activity_type_name.is_a?(String) ||
        activity_type_name.is_a?(Symbol)

      activity_type_name = activity_type_name.to_sym
      result = @activity_types.find { |t| t.name == activity_type_name }

      raise ArgumentError unless result

      result
    end

    def all
      @activity_types
    end

    def self.instance
      @instance ||= ActivityTypeRepository.new
    end

    def self.reset
      @instance = nil
    end

    private

    def initialize
      @activity_types = []
    end
  end
end
