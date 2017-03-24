require 'active_support/concern'

module ActivityTracker
  module HasActivities
    extend ActiveSupport::Concern

    included do
      has_many :activities, as: :subject, dependent: :destroy

      def track_activity(receivers, type, options = {})
        if self.is_a?(ActiveRecord::Base) && !options.include?(:subject)
          options[:subject] = self
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
