require 'active_support/concern'

module ActivityTracker
  module UserModel
    extend ActiveSupport::Concern

    included do
      has_many ActivityTracker.configuration.activity_class.underscore.pluralize.to_sym, foreign_key: 'sender_id'
      has_many ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym, foreign_key: 'receiver_id'
      has_many ActivityTracker.configuration.notification_class.underscore.pluralize.to_sym, through: ActivityTracker.configuration.notification_batch_class.underscore.pluralize.to_sym

      def type
        ActivityTracker::ActivityTypeRepository.instance.get(activity_type)
      end

      def notification_level(activity_type)
        @notification_setting_repository = ActivityTracker::NotificationSettingRepository.new
        user_level = @notification_setting_repository.get(id, activity_type).try(:level)

        user_level || ActivityTracker::ActivityTypeRepository.instance.get(activity_type).level
      end
    end
  end
end
