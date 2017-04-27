require 'spec_helper'

describe ActivityTracker::ActivityRepository do
  let(:instance) { ActivityTracker::ActivityRepository.new }

  describe '#add' do
    it 'requires an Activity object' do
      expect { instance.add }.to raise_exception(ArgumentError)
      expect { instance.add('abc') }.to raise_exception(ArgumentError)
      expect { instance.add(222.33) }.to raise_exception(ArgumentError)
    end

    it 'saves the activity' do
      activity = build :activity

      expect(instance.add(activity)).to eq(true)
      expect(instance.all.count).to eq(1)
    end
  end

  describe '#factory' do
    it 'returns the right object types' do
      activity = instance.factory(activity_type: 'type1')
      expect(activity).to be_a(Activity)
      expect(activity.type).to be_a(ActivityTracker::ActivityType)
    end
  end

  describe '#all' do
    it 'returns no objects if empty' do
      expect(instance.all.count).to eq(0)
    end
  end
end
