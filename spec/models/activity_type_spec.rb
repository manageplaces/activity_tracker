require 'spec_helper'

describe ActivityTracker::ActivityType do
  describe 'initializer' do
    it 'has a valid factory' do
      expect(build(:activity_type)).to be_a(ActivityType)
    end
    it 'has a valid initializer' do
      expect(ActivityTracker::ActivityType.new(name: 'task.updated')).to be_a(ActivityTracker::ActivityType)
    end
  end
end
