require 'spec_helper'

describe ActivityTracker::ActivityBatchRepository do
  let(:instance) { ActivityTracker::ActivityBatchRepository.new }

  let(:user) { create :user }
  let(:user_id) { user.id }

  let(:user2) { create :user }
  let(:user2_id) { user2.id }

  describe '#add' do
    it 'requires an ActivityBatch object' do
      expect { instance.add }.to raise_exception(ArgumentError)
      expect { instance.add('abc') }.to raise_exception(ArgumentError)
      expect { instance.add(222.33) }.to raise_exception(ArgumentError)
    end

    it 'saves the activity' do
      activity_batch = build :activity_batch

      expect(instance.add(activity)).to eq(true)
      expect(instance.all.count).to eq(1)
    end
  end

  describe '#all' do
    it 'returns no objects if empty' do
      expect(instance.all.count).to eq(0)
    end
  end

  describe '#create' do

    it 'creates an ActivityBatch object' do
      activity_batch = instance.create(user_id)
      expect(activity_batch).to be_a(ActivityBatch)
      expect(activity_batch.persisted?).to eq(false)
    end
  end

  describe '#find_or_create' do

  end
end
