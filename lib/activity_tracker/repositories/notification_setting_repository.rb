module ActivityTracker
  class NotificationSettingRepository
    def initialize(class_name = nil)
      class_name ||= ActivityTracker.configuration.notification_setting_class

      class_name = class_name
      @klass = class_name.constantize
      @foreign_key = "#{class_name.underscore}_id".to_sym
      @relation_name = class_name.underscore.to_sym
      @plural_relation_name = class_name.underscore.pluralize.to_sym
    end

    def add(notification_setting)
      raise ArgumentError unless notification_setting.is_a?(@klass)

      notification_setting.save
    end

    def all
      @klass.all
    end
  end
end
