require 'spec_helper'

describe ActivityTracker.batch do
  before :all do
    load File.dirname(__FILE__) + '/support/activity_types.rb'
  end

  let(:user1) { create :user }

  let(:task) { create :task }

  specify 'when batch called without any activities' do
    ActivityTracker.batch { 2 + 2 }

    expect(ActivityTracker::ActivityRepository.new.all.count).to eq(0)
    expect(ActivityTracker::ActivityBatchRepository.new.all.count).to eq(0)
  end

  specify 'when batch called with one activity and one receiver' do
    user1.id

    ActivityTracker.batch do
      user = user1
      task.instance_eval { track_activity(user, :type1) }
    end

    activities = Activity.all
    expect(activities.count).to eq(1)
  end
end
