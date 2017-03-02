require 'spec_helper'

describe ActivityTracker::ActivityType do
  let(:instance) { ActivityTracker::ActivityType.instance }

  describe '.instance' do
    it 'returns a repository object' do
      expect(instance).to be_a(ActivityTracker::ActivityType)
    end
  end

  describe 'get' do
    
  end
end
