require 'active_support/concern'

module ActivityTracker
  module ActivityModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym, dependent: :destroy
      has_many ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym, through: ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym

      belongs_to :sender, class_name: ActivityTracker.configuration.user_class, optional: true
      belongs_to :scope, polymorphic: true
      belongs_to :resource, polymorphic: true

      validates_presence_of :activity_type

      before_validation :auto_scope_resource

      def type
        activity_type ? ::ActivityTracker::ActivityTypeRepository.instance.get(activity_type) : nil
      end

      protected

      def auto_scope_resource
        self.resource = scope if scope && !resource
        self.scope = resource if !scope && resource
      end
    end
  end
end
