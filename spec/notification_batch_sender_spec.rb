

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
  let(:notification_batch_empty) { create :notification_batch, is_closed: true }
  let(:notification_batch_single_notification) do
    create :notification_batch, is_closed: true
    nb = create :notification_batch, is_closed: true
    nb.notifications << notification1
    nb
  end

  specify 'when initialised with no params' do
    expect do
      ns = ActivityTracker::NotificationBatchSender.new
    end.to raise_error(ArgumentError)
  end

  specify 'when initialised without any notifications' do
    ns = ActivityTracker::NotificationBatchSender.new(notification_batch_empty)
    ns.process

    expect(probe).to eq([])
  end

  specify 'when initialised with a single notification' do
    ns = ActivityTracker::NotificationBatchSender.new(notification_batch_single_notification)
    ns.process

    expect(probe.count).to eq(1)
    expect(probe.first).to eq([notification_batch_single_notification.receiver, notification_batch_single_notification.notifications.to_a])
  end
end
