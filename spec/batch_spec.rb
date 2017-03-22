require 'spec_helper'

describe ActivityTracker.batch do
  before :all do
    load File.dirname(__FILE__) + '/support/activity_types.rb'
  end

  let(:user1) { create :user }
  let(:user2) { create :user }

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
    activity = activities.first

    expect(activities.count).to eq(1)
    expect(activity.activity_batches.count).to eq(1)
    expect(activity.activity_batches.first.receiver_id).to eq(user1.id)
  end

  specify 'when batch called with batch param' do
    user1.id

    ActivityTracker.batch(sender: user2) do
      user = user1
      task.instance_eval { track_activity(user, :type1) }
    end

    activities = Activity.all
    activity = activities.first

    expect(activities.count).to eq(1)
    expect(activity.sender).to eq(user2)
    expect(activity.activity_batches.count).to eq(1)
    expect(activity.activity_batches.first.receiver_id).to eq(user1.id)
  end

  describe 'type filters' do
    specify 'when batch called with both :only and :without params' do
      expect do
        ActivityTracker.batch(only: [:type1], without: [:type2])
      end.to raise_error(ArgumentError)
    end

    it 'skips all activities except the :only ones' do
      user1.id

      ActivityTracker.batch(sender: user2, only: [:type1]) do
        user = user1
        task.instance_eval { track_activity(user, :type1) }
        task.instance_eval { track_activity(user, :type2) }
      end

      activities = Activity.all
      activity = activities.first

      expect(activities.count).to eq(1)
      expect(activity.activity_type.to_sym).to eq(:type1)
    end

    it 'skips the :without specified activities' do
      user1.id

      ActivityTracker.batch(sender: user2, without: [:type1]) do
        user = user1
        task.instance_eval { track_activity(user, :type1) }
        task.instance_eval { track_activity(user, :type2) }
      end

      activities = Activity.all
      activity = activities.first

      expect(activities.count).to eq(1)
      expect(activity.activity_type.to_sym).to eq(:type2)
    end
  end

  describe 'unbatchable activities' do
    it 'does not batch unbatchable activities' do
      ActivityTracker.batch(sender: user2, without: [:type1]) do
        user = user1
        task.instance_eval { track_activity(user, :type2) }
        task.instance_eval { track_activity(user, :unbatchable_type_1) }
      end

      expect(ActivityBatch.all.count).to eq(2)
    end
  end
end
