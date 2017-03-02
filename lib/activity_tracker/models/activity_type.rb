module ActivityTracker
  class ActivityType
    attr_reader :name

    def initialize(params)
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
