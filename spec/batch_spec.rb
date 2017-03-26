require 'spec_helper'

describe ActivityTracker.batch do
  before :all do
    load File.dirname(__FILE__) + '/support/activity_types.rb'
  end

  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }

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
      activities_hidden = Activity.where(is_hidden: true)
      activity = activities.first

      expect(activities.count).to eq(2)
      expect(activities_hidden.count).to eq(1)
      expect(activities.first.activity_type.to_sym).to eq(:type1)
      expect(activities.first.is_hidden).to eq(false)
      expect(activities.second.activity_type.to_sym).to eq(:type2)
      expect(activities.second.is_hidden).to eq(true)
    end

    it 'skips the :without specified activities' do
      user1.id

      ActivityTracker.batch(sender: user2, without: [:type1]) do
        user = user1
        task.instance_eval { track_activity(user, :type1) }
        task.instance_eval { track_activity(user, :type2) }
      end

      activities = Activity.all
      activities_hidden = Activity.where(is_hidden: true)
      activity = activities.first

      expect(activities.count).to eq(2)
      expect(activities_hidden.count).to eq(1)
      expect(activities.first.activity_type.to_sym).to eq(:type1)
      expect(activities.first.is_hidden).to eq(true)
      expect(activities.second.activity_type.to_sym).to eq(:type2)
      expect(activities.second.is_hidden).to eq(false)
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
        task.instance_eval { track_activity(users, :notifications_disabled) }
      end

      expect(NotificationBatch.all.count).to eq(0)
    end
  end

  describe 'user level notification levels' do
    specify 'when default actiivty level is disabled' do
      create :notification_setting, activity_type: :notifications_disabled, user: user1, level: ActivityTracker::NotificationLevels::DISABLED
      create :notification_setting, activity_type: :notifications_disabled, user: user2, level: ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      create :notification_setting, activity_type: :notifications_disabled, user: user3, level: ActivityTracker::NotificationLevels::EMAIL

      ActivityTracker.batch do
        users = [user1, user2, user3, user4]
        task.instance_eval { track_activity(users, :notifications_disabled) }
      end

      notification_batches = NotificationBatch.all
      notifications = Notification.all

      expect(notification_batches.count).to eq(2)
      expect(notification_batches.first.receiver_id).to eq(user2.id)
      expect(notification_batches.second.receiver_id).to eq(user3.id)
      expect(notifications.first.send_mail).to eq(false)
      expect(notifications.second.send_mail).to eq(true)
    end

    specify 'when default actiivty level is notifications only' do
      create :notification_setting, activity_type: :notifications_notification_only, user: user1, level: ActivityTracker::NotificationLevels::DISABLED
      create :notification_setting, activity_type: :notifications_notification_only, user: user2, level: ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      create :notification_setting, activity_type: :notifications_notification_only, user: user3, level: ActivityTracker::NotificationLevels::EMAIL

      ActivityTracker.batch do
        users = [user1, user2, user3, user4]
        task.instance_eval { track_activity(users, :notifications_notification_only) }
      end

      notification_batches = NotificationBatch.all
      notifications = Notification.all

      expect(notification_batches.count).to eq(3)
      expect(notification_batches.first.receiver_id).to eq(user2.id)
      expect(notification_batches.second.receiver_id).to eq(user3.id)
      expect(notification_batches.third.receiver_id).to eq(user4.id)
      expect(notifications.first.send_mail).to eq(false)
      expect(notifications.second.send_mail).to eq(true)
      expect(notifications.third.send_mail).to eq(false)
    end

    specify 'when default actiivty level is email' do
      create :notification_setting, activity_type: :notifications_email, user: user1, level: ActivityTracker::NotificationLevels::DISABLED
      create :notification_setting, activity_type: :notifications_email, user: user2, level: ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      create :notification_setting, activity_type: :notifications_email, user: user3, level: ActivityTracker::NotificationLevels::EMAIL

      ActivityTracker.batch do
        users = [user1, user2, user3, user4]
        task.instance_eval { track_activity(users, :notifications_email) }
      end

      notification_batches = NotificationBatch.all
      notifications = Notification.all

      expect(notification_batches.count).to eq(3)
      expect(notification_batches.first.receiver_id).to eq(user2.id)
      expect(notification_batches.second.receiver_id).to eq(user3.id)
      expect(notification_batches.third.receiver_id).to eq(user4.id)
      expect(notifications.first.send_mail).to eq(false)
      expect(notifications.second.send_mail).to eq(true)
      expect(notifications.third.send_mail).to eq(true)
    end
  end
end
