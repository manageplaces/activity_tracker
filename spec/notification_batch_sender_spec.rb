
require 'spec_helper'

probe = []

def reset_probe
  probe = []
end

describe ActivityTracker::NotificationBatchSender do

  before(:all) do
    ActivityTracker.configure do |c|
      c.default_mailer = lambda do |user, activities|
        probe << [user, activities]
      end
    end
  end

  before(:each) { reset_probe }

  let(:notification1) { build :notification }
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

  specify 'when initialised with no params' do
    expect do
      ns = ActivityTracker::NotificationBatchSender.new
    end.to raise_error(ArgumentError)
  end

  specify 'when initialised without any notifications' do
    ns = ActivityTracker::NotificationBatchSender.new(notification_batch_empty)
    expect(ns.process).to eq(true)

    expect(probe).to eq([])

    notification_batch_empty.reload
    expect(notification_batch_empty.is_sent).to eq(true)
  end

  specify 'when initialised with a single notification' do
    ns = ActivityTracker::NotificationBatchSender.new(notification_batch_single_notification)

    expect(ns.process).to eq(true)
    expect(probe.count).to eq(1)
    expect(probe.first).to eq([notification_batch_single_notification.receiver, notification_batch_single_notification.notifications.to_a])

    notification_batch_single_notification.reload
    expect(notification_batch_single_notification.is_sent).to eq(true)
  end
end
