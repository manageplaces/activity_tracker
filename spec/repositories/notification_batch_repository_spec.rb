require 'spec_helper'

describe ActivityTracker::NotificationBatchRepository do
  let(:instance) { ActivityTracker::NotificationBatchRepository.new }

  let(:user) { create :user }
  let(:user_id) { user.id }

  let(:user2) { create :user }
  let(:user2_id) { user2.id }

  describe '#add' do
    it 'requires an NotificationBatch object' do
      expect { instance.add }.to raise_exception(ArgumentError)
      expect { instance.add('abc') }.to raise_exception(ArgumentError)
      expect { instance.add(222.33) }.to raise_exception(ArgumentError)
    end

    it 'saves the activity' do
      notification_batch = build :notification_batch

      expect(instance.add(notification_batch)).to eq(true)
      expect(instance.all.count).to eq(1)
    end
  end

  describe '#all' do
    it 'returns no objects if empty' do
      expect(instance.all.count).to eq(0)
    end
  end

  describe '#create' do

    it 'creates an NotificationBatch object' do
      notification_batch = instance.create(user_id)
      expect(notification_batch).to be_a(NotificationBatch)
      expect(notification_batch.persisted?).to eq(false)
    end
  end

  describe '#pending_to_send' do
    let!(:notification_batch) { create :notification_batch }
    let!(:notification_batch_old) { create :notification_batch, :old }

    it 'fetches only old ones' do
      expect(instance.pending_to_send).to eq([notification_batch_old])
    end
  end
end
