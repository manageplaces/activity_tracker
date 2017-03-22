module ActivityTracker
  class ActivityBatchRepository
    def initialize(class_name = nil)
      class_name ||= ActivityTracker.configuration.activity_batch_class

      @class_name = class_name
      @klass = class_name.constantize
      @foreign_key = "#{class_name.underscore}_id".to_sym
      @relation_name = class_name.underscore.to_sym
      @plural_relation_name = class_name.underscore.pluralize.to_sym
    end

    def create(user_id, is_closed = false)
      @klass.new(
        receiver_id: user_id,
        is_closed: is_closed
      )
    end

    def find_or_create(user_id, is_closed = false)
      return create(user_id, true) if is_closed

      @klass.where(
        'receiver_id = ? AND (created_at > ? or last_activity > ?)',
        user_id,
        DateTime.now - ActivityTracker.configuration.lifetime.seconds,
        DateTime.now - ActivityTracker.configuration.idle_time.seconds
      ).order('last_activity desc').first || create(user_id, is_closed)
    end

    def add(activity_batch)
      raise ArgumentError unless activity_batch.is_a?(@klass)

      activity_batch.save
    end

    def all
      @klass.all
    end
  end
end
