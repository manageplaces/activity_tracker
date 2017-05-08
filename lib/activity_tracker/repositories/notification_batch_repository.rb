module ActivityTracker
  class NotificationBatchRepository
    def initialize(class_name = nil)
      class_name ||= ActivityTracker.configuration.notification_batch_class

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

    def pending_to_send
      @klass.where(
        'is_sent = ? AND (created_at <= ? and last_activity <= ?)',
        false,
        Time.zone.now - ActivityTracker.configuration.lifetime.seconds,
        Time.zone.now - ActivityTracker.configuration.idle_time.seconds
      )
    end

    def find_or_create(user_id, is_closed = false)
      return create(user_id, true) if is_closed

      @klass.where(
        'receiver_id = ? AND (created_at > ? or last_activity > ?)',
        user_id,
        Time.zone.now - ActivityTracker.configuration.lifetime.seconds,
        Time.zone.now - ActivityTracker.configuration.idle_time.seconds
      ).order('last_activity desc').first || create(user_id, is_closed)
    end

    def add(notification_batch)
      raise ArgumentError unless notification_batch.is_a?(@klass)

      notification_batch.save!
    end

    def all
      @klass.all
    end
  end
end
