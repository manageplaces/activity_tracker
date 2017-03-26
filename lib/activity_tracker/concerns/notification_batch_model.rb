require 'active_support/concern'

module ActivityTracker
  module NotificationBatchModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym

      has_many ActivityTracker.configuration.activity_class.underscore.pluralize.to_sym, after_add: :update_last_activity, through: ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym
      belongs_to :receiver, class_name: ActivityTracker.configuration.user_class

      validates_presence_of :receiver
      validates_inclusion_of :is_closed, in: [true, false]
      validates_inclusion_of :is_sent, in: [true, false]

      before_validation :update_last_activity

      protected

      def update_last_activity(_activity = nil)
        self.last_activity = [
          _activity.try(:created_at), last_activity].compact.max || DateTime.now
      end
    end
  end
end
