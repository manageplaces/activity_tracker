require 'active_support/concern'

module ActivityTracker
  module HasActivity
    extend ActiveSupport::Concern

    included do
      def track_activity(*params)
        return unless ::ActivityTracker::CollectorRepository.instance.exists?

        activity = ::ActivityTracker::ActivityRepository.factory(params)
        collector = ::ActivityTracker.CollectorRepository.instance.get

        collector.add(activity)
      end
    end
  end
end
