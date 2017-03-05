module ActivityTracker
  def self.define_activity(&block)
    repository = ActivityTypeRepository.instance
    activity_type = ActivityType.new(&block)
    repository.add(activity_type)
  end
end
