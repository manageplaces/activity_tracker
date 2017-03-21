module ActivityTracker
  def self.track_activity(receivers, type, options = {})
    return unless ::ActivityTracker::CollectorRepository.instance.exists?

    collector = ::ActivityTracker::CollectorRepository.instance.get

    options[:receivers] = receivers.is_a?(Array) ? receivers : [receivers]
    options[:activity_type] = type

    collector.add(options)
  end
end
