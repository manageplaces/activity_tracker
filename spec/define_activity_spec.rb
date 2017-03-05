require 'spec_helper'

describe ActivityTracker.define_activity do
  specify 'when block given' do
    ActivityTracker::ActivityTypeRepository.reset
    repository = ActivityTracker::ActivityTypeRepository.instance

    ActivityTracker.define_activity do
      name 'type1'
    end

    expect(repository.all.count).to eq(1)
  end
end
