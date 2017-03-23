ActivityTracker::ActivityTypeRepository.reset

ActivityTracker.define_activity do
  name 'type1'
end

ActivityTracker.define_activity do
  name 'type2'
end

ActivityTracker.define_activity do
  name 'unbatchable_type_1'
  batchable false
end

ActivityTracker.define_activity do
  name 'no_skip_sender_type_1'
  skip_sender false
end
