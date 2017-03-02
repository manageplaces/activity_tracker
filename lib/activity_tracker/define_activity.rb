module ActivityTracker
  def define_activity(&block)
    obj = ::ActivityTracker::Factory.new(&block)

    ::ActivityTracker::ActiivtyTypeRepository.add(obj)
  end
end
