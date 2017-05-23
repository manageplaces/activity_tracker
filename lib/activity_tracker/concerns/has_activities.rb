require 'active_support/concern'

module ActivityTracker
  module HasActivities
    extend ActiveSupport::Concern

    included do
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
