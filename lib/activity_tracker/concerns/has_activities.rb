require 'active_support/concern'

module ActivityTracker
  module HasActivities
    extend ActiveSupport::Concern

    included do
      has_many :scope_activities, as: :resource, dependent: :destroy
      has_many :resource_activities, as: :resource, dependent: :destroy

      def track_activity(receivers, type, options = {})
        if self.is_a?(ActiveRecord::Base) && !options.include?(:scope)
          options[:scope] = self
        end

        ::ActivityTracker.track_activity(receivers, type, options)
      end
    end

    module ClassMethods
      def track_activity(receivers, type, options = {})
        ::ActivityTracker.track_activity(receivers, type, options)
      end
    end
  end
end
