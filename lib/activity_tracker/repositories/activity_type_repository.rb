module ActivityTracker
  class ActivityTypeRepository
    def metadata_fields
      @metadata_fields
    end

    def add(activity_type = nil)
      raise ArgumentError unless activity_type.is_a?(ActivityType)
      type = activity_type.name.try(:to_sym)

      raise ArgumentError unless type
      @activity_types[type] = activity_type

      changed_metadata = false

      if activity_type.metadata_fields
        activity_type.metadata_fields.each do |field|
          unless @metadata_fields.include?(field)
            @metadata_fields << field
            changed_metadata = true
          end
        end
      end

      # inject_metadata_fields if changed_metadata
    end

    def get(activity_type_name)
      raise ArgumentError unless activity_type_name.is_a?(String) ||
        activity_type_name.is_a?(Symbol)

      activity_type_name = activity_type_name.to_sym
      result = @activity_types[activity_type_name]

      raise ArgumentError unless result

      result
    end

    def all
      @activity_types.values
    end

    def no_notifications
      all.reject(&:no_notifications)
    end

    def self.instance
      @instance ||= ActivityTypeRepository.new
    end

    def self.reset
      @instance = nil
    end

    private

    def inject_metadata_fields
      return if @metadata_fields.nil? || @metadata_fields.empty?

      m = @metadata_fields

      ActivityTracker.configuration.activity_class.constantize.instance_eval do
        store :metadata, accessors: m, coder: JSON
      end
    end

    def initialize
      @activity_types = {}
      @metadata_fields = []
    end
  end
end
