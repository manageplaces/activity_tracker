require 'spec_helper'

describe ActivityTracker.batch do
  before :all do
    load File.dirname(__FILE__) + '/support/activity_types.rb'
  end

  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }

  let(:task) { create :task }

  specify 'when batch called without any activities' do
    ActivityTracker.batch { 2 + 2 }

    expect(ActivityTracker::ActivityRepository.new.all.count).to eq(0)
    expect(ActivityTracker::NotificationBatchRepository.new.all.count).to eq(0)
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
    expect(activity.notification_batches.count).to eq(1)
    expect(activity.notification_batches.first.receiver_id).to eq(user1.id)
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
    expect(activity.notification_batches.count).to eq(1)
    expect(activity.notification_batches.first.receiver_id).to eq(user1.id)
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

      expect(NotificationBatch.all.count).to eq(2)
      expect(NotificationBatch.where(is_closed: true).count).to eq(1)
      expect(NotificationBatch.where(is_closed: false).count).to eq(1)
    end
  end

  describe 'skip_sender option' do
    it 'is enabled by default' do
      ActivityTracker.batch(sender: user1) do
        users = [user1, user2]
        task.instance_eval { track_activity(users, :type2) }
      end

      expect(NotificationBatch.all.count).to eq(1)
    end

    it 'does not skip senders if disabled' do
      ActivityTracker.batch(sender: user1) do
        users = [user1, user2]
        task.instance_eval { track_activity(users, :no_skip_sender_type_1) }
      end

      expect(NotificationBatch.all.count).to eq(2)
    end
  end

  describe 'notification levels' do
    it 'skips sending notifications if disabled by default' do
      ActivityTracker.batch do
        users = [user1, user2]
        task.instance_eval { track_activity(users, :disabled_notifications) }
      end

      expect(NotificationBatch.all.count).to eq(0)
    end
  end

  describe 'user level notification levels' do
    it 'is possible to enable by overriding' do
      create :notification_setting, activity_type: :disabled_notifications, user: user1
      create :notification_setting, activity_type: :disabled_notifications, user: user2, level: ActivityTracker::NotificationLevels::DISABLED

      ActivityTracker.batch do
        users = [user1, user2, user3]
        task.instance_eval { track_activity(users, :disabled_notifications) }
      end

      expect(NotificationBatch.all.count).to eq(1)
      expect(NotificationBatch.all.first.receiver_id).to eq(user1.id)
    end

    it 'is possible to enable by overriding' do
      create :notification_setting, user: user1
      create :notification_setting, user: user2, level: ActivityTracker::NotificationLevels::DISABLED

      ActivityTracker.batch do
        users = [user1, user2, user3]
        task.instance_eval { track_activity(users, :type1) }
      end

      expect(NotificationBatch.all.count).to eq(2)
      expect(NotificationBatch.all.first.receiver_id).to eq(user1.id)
      expect(NotificationBatch.all.second.receiver_id).to eq(user3.id)
    end
  end
end
