module ActivityTracker
  class ActivityRepository
    def initialize(class_name = nil)
      class_name ||= ActivityTracker.configuration.activity_class

      class_name = class_name
      @klass = class_name.constantize
      @foreign_key = "#{class_name.underscore}_id".to_sym
      @relation_name = class_name.underscore.to_sym
      @plural_relation_name = class_name.underscore.pluralize.to_sym
    end

    def add(activity)
      raise ArgumentError unless activity.is_a?(@klass)

      activity.save!
    end

    def all
      @klass.all
    end

    def factory(params)
      activity = @klass.new

      params.each { |k, v| activity.send("#{k}=".to_sym, v) }

      activity
    end
  end
end
