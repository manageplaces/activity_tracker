require 'active_support/concern'

module ActivityTracker
  module ActivityModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym
      has_many ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym, through: ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym

      belongs_to :sender, class_name: ActivityTracker.configuration.user_class
      belongs_to :scope, polymorphic: true

      validates_presence_of :activity_type, :scope

      def type
        activity_type ? ::ActivityTracker::ActivityTypeRepository.instance.get(activity_type) : nil
      end
    end
  end
end
