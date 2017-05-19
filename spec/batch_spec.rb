require 'spec_helper'

probe = []

def reset_probe
  probe = []
end

describe 'ActivityTracker.batch' do
  before(:all) do
    load File.dirname(__FILE__) + '/support/activity_types.rb'

    ActivityTracker.configure do |c|
      c.default_mailer = lambda do |user, activities|
        probe << [user, activities]
      end
    end
  end

  before(:each) { reset_probe }

  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }
  let(:user_skip_notifications) { create :user, :skip_notifications }

  let(:task) { create :task }
  let(:task2) { create :task }
  let(:task3) { create :task }

  specify 'when batch called without any activities' do
    ActivityTracker.batch { 2 + 2 }

    expect(ActivityTracker::ActivityRepository.new.all.count).to eq(0)
    expect(ActivityTracker::NotificationBatchRepository.new.all.count).to eq(0)
  end

  specify 'when batch called with one activity and one receiver' do
    user1.id

    returned_activities = ActivityTracker.batch do
      user = user1
      task.instance_eval { track_activity(user, :type1) }
    end

    activities = Activity.all
    activity = activities.first

    expect(returned_activities.count).to eq(1)
    expect(returned_activities).to eq(activities)
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
    expect(probe.count).to eq(0)
  end

  describe 'type filters - activities' do
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

      expect(activities.count).to eq(1)
      expect(activities_hidden.count).to eq(0)
      expect(activity.activity_type.to_sym).to eq(:type1)
      expect(activity.is_hidden).to eq(false)
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

      expect(activities.count).to eq(1)
      expect(activities_hidden.count).to eq(0)
      expect(activity.activity_type.to_sym).to eq(:type2)
      expect(activity.is_hidden).to eq(false)
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
      expect(probe.count).to eq(1)
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

  describe 'global receivers filter' do
    before do
      ActivityTracker.configure do |c|
        c.receivers_filter = ->(user) { !user.skip_notifications }
      end
    end

    after do
      ActivityTracker.configure do |c|
        c.receivers_filter = nil
      end
    end

    it 'skips users' do
      ActivityTracker.batch do
        users = [user1, user_skip_notifications]
        task.instance_eval { track_activity(users, :type1) }
      end

      activities = Activity.all
      activity = activities.first

      expect(activities.count).to eq(1)
      expect(activity.notification_batches.count).to eq(1)
      expect(activity.notification_batches.first.receiver_id).to eq(user1.id)
    end
  end

  describe 'scope filters' do
    it 'skips skips scopes' do
      ActivityTracker.batch(sender: user1, scope_filter: task) do
        users = [user2, user3]

        task.instance_eval { track_activity(users.dup, :type1, scope: self) }
        task2.instance_eval { track_activity(users.dup, :type1, scope: self) }
        task3.instance_eval { track_activity(users.dup, :type1, scope: self) }
      end

      activities = Activity.all
      activities_hidden = Activity.where(is_hidden: true)

      expect(activities.count).to eq(3)
      expect(activities_hidden.count).to eq(2)

      cnt = Notification.all.select { |n| n.activity.scope != task }.count
      expect(cnt).to eq(0)
    end

    it 'skips skips scopes when array passed' do
      ActivityTracker.batch(sender: user1, scope_filter: [task, task2]) do
        users = [user2, user3]

        task.instance_eval { track_activity(users.dup, :type1, scope: self) }
        task2.instance_eval { track_activity(users.dup, :type1, scope: self) }
        task3.instance_eval { track_activity(users.dup, :type1, scope: self) }
      end

      activities = Activity.all
      activities_hidden = Activity.where(is_hidden: true)

      expect(activities.count).to eq(3)
      expect(activities_hidden.count).to eq(1)
      expect(Notification.all.select { |n| n.activity.scope == task3 }.count).to eq(0)
    end
  end

  describe 'type filters - notifications' do
    specify 'when batch called with both :only and :without params' do
      expect do
        ActivityTracker.batch(notifications: { only: [:type1], without: [:type2] })
      end.to raise_error(ArgumentError)
    end

    it 'skips all activities except the :only ones' do
      user1.id

      ActivityTracker.batch(sender: user2, notifications: { only: [:type1] }) do
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

      ActivityTracker.batch(sender: user2, notifications: { without: [:type1] }) do
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
      user1.notification_settings[:notifications_disabled] = ActivityTracker::NotificationLevels::DISABLED
      user2.notification_settings[:notifications_disabled] = ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      user3.notification_settings[:notifications_disabled] = ActivityTracker::NotificationLevels::EMAIL
      user1.save
      user2.save
      user3.save

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
      user1.notification_settings[:notifications_notification_only] = ActivityTracker::NotificationLevels::DISABLED
      user2.notification_settings[:notifications_notification_only] = ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      user3.notification_settings[:notifications_notification_only] = ActivityTracker::NotificationLevels::EMAIL
      user1.save
      user2.save
      user3.save

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
      user1.notification_settings[:notifications_email] = ActivityTracker::NotificationLevels::DISABLED
      user2.notification_settings[:notifications_email] = ActivityTracker::NotificationLevels::NOTIFICATION_ONLY
      user3.notification_settings[:notifications_email] = ActivityTracker::NotificationLevels::EMAIL
      user1.save
      user2.save
      user3.save

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
