require 'spec_helper'

describe ActivityTracker::NotificationBatchSender do
  let(:activity_type_probe) { [] }
  let(:activity_type_probe_block) do
    lambda do |user, activities|
      activity_type_probe << [user, activities]
    end
  end
  let(:probe) { [] }
  let(:probe_block) do
    lambda do |user, activities|
      probe << [user, activities]
    end
  end
  let(:notification1) { build :notification }
  let(:notification_custom_mailer) do
    build :notification, activity: custom_mailer_activity
  end
  let(:notification_batch_amendable) do
    create :notification_batch, created_at: Time.zone.now, is_sent: false
  end
  let(:custom_mailer_activity) do
    build :activity, activity_type: :custom_mailer_type
  end
  let(:notification_batch_empty) do
    create :notification_batch, :old, is_closed: true
  end
  let(:notification_batch_single_notification) do
    nb = create :notification_batch, :old, is_closed: true
    nb.notifications << notification1
    nb.last_activity = 1.week.ago
    nb.save
    nb
  end
  let(:notification_batch_multiple_notifications) do
    nb = create :notification_batch, :old, is_closed: true
    nb.notifications << notification1
    nb.notifications << notification_custom_mailer
    nb.last_activity = 1.week.ago
    nb.save
    nb
  end
  let(:notification_batch_custom_mailer) do
    nb = create :notification_batch, :old, is_closed: true
    nb.notifications << notification_custom_mailer
    nb.last_activity = 1.week.ago
    nb.save
    nb
  end

  before(:each) do
    ActivityTracker.configure do |c|
      c.default_mailer = probe_block
    end

    type = ActivityTracker::ActivityType.new(
      name: 'custom_mailer_type',
      mailer: activity_type_probe_block
    )
    ActivityTracker::ActivityTypeRepository.instance.add(type)
  end

  specify 'when initialised with no params' do
    expect do
      ActivityTracker::NotificationBatchSender.new
    end.to raise_error(ArgumentError)
  end

  specify 'when notification is not closed' do
    ns = ActivityTracker::NotificationBatchSender.new(
      notification_batch_amendable
    )

    expect(ns.process).to eq(false)
    expect(probe.count).to eq(0)

    notification_batch_single_notification.reload
    expect(notification_batch_amendable.is_sent).to eq(false)
  end

  specify 'when initialised without any notifications' do
    ns = ActivityTracker::NotificationBatchSender.new(notification_batch_empty)
    expect(ns.process).to eq(true)

    expect(probe).to eq([])

    notification_batch_empty.reload
    expect(notification_batch_empty.is_sent).to eq(true)
  end

  specify 'when initialised with a single notification' do
    ns = ActivityTracker::NotificationBatchSender.new(
      notification_batch_single_notification
    )

    expect(ns.process).to eq(true)
    expect(probe.count).to eq(1)
    expect(probe.first).to eq(
      [notification_batch_single_notification.receiver,
       notification_batch_single_notification.activities]
    )

    notification_batch_single_notification.reload
    expect(notification_batch_single_notification.is_sent).to eq(true)
  end

  specify 'when initialised with a multiple notifications' do
    ns = ActivityTracker::NotificationBatchSender.new(
      notification_batch_multiple_notifications
    )

    expect(ns.process).to eq(true)
    expect(probe.count).to eq(1)
    expect(probe.first).to eq(
      [notification_batch_multiple_notifications.receiver,
       notification_batch_multiple_notifications.activities]
    )

    notification_batch_multiple_notifications.reload
    expect(notification_batch_multiple_notifications.is_sent).to eq(true)
  end

  specify 'when initialised with a custom mailer notification' do
    ns = ActivityTracker::NotificationBatchSender.new(
      notification_batch_custom_mailer
    )

    expect(ns.process).to eq(true)
    expect(probe.count).to eq(0)
    expect(activity_type_probe.count).to eq(1)
    expect(activity_type_probe.first).to eq(
      [notification_batch_custom_mailer.receiver,
       notification_batch_custom_mailer.activities]
    )

    notification_batch_custom_mailer.reload
    expect(notification_batch_custom_mailer.is_sent).to eq(true)
  end
end
