require 'active_support/concern'

module ActivityTracker
  module NotificationBatchModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym
      has_many ActivityTracker.configuration.activity_class.underscore.pluralize.to_sym, after_add: :update_last_activity, through: ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym
      belongs_to :receiver, class_name: ActivityTracker.configuration.user_class

      validates_inclusion_of :is_closed, in: [true, false]
      validates_inclusion_of :is_sent, in: [true, false]

      before_validation :update_last_activity

      def amendable?
        !is_closed &&
        created_at > (Time.zone.now - ActivityTracker.configuration.lifetime.seconds) &&
        last_activity > (Time.zone.now - ActivityTracker.configuration.idle_time.seconds)
      end

      protected

      def update_last_activity(activity = nil)
        self.last_activity = [
          activity.try(:created_at), last_activity].compact.max || Time.zone.now
      end
    end
  end
end
