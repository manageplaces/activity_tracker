require 'active_support/concern'

module ActivityTracker
  module NotificationSettingModel
    extend ActiveSupport::Concern

    included do
      belongs_to ActivityTracker.configuration.user_class.underscore.to_sym

      validates_inclusion_of :level, in: ActivityTracker::NotificationLevels::TYPES
      validates_presence_of :activity_type, :level, :user
      validates_uniqueness_of :activity_type, scope: :user_id
    end
  end
end
