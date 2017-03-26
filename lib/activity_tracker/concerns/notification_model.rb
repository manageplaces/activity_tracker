require 'active_support/concern'

module ActivityTracker
  module NotificationModel
    extend ActiveSupport::Concern

    included do
      belongs_to ActivityTracker.configuration.notification_batch_class.underscore.to_sym
      belongs_to ActivityTracker.configuration.activity_class.underscore.to_sym
    end
  end
end
