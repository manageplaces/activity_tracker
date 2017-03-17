require 'active_support/concern'

module ActivityTracker
  module HasActivities
    extend ActiveSupport::Concern

    included do
      has_many :activities, as: :resource, dependent: :destroy

      def track_activity(receivers, type, options = {})
        return unless ::ActivityTracker::CollectorRepository.instance.exists?

        collector = ::ActivityTracker::CollectorRepository.instance.get

        options[:receivers] = receivers
        options[:type] = type

        collector.add(options)
      end
    end
  end
end
