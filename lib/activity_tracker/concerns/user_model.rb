require 'active_support/concern'

module ActivityTracker
  module UserModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.activity_class.underscore.pluralize.to_sym, foreign_key: 'sender_id', dependent: :nullify
      has_many ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym, foreign_key: 'receiver_id', dependent: :destroy
      has_many ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym, through: ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym

      store :notification_settings, coder: JSON

      def type
        ActivityTracker::ActivityTypeRepository.instance.get(activity_type)
      end

      def notification_level(activity_type)
        user_level = notification_settings[activity_type]
        user_level || ActivityTracker::ActivityTypeRepository.instance.get(activity_type).level
      end
    end
  end
end
