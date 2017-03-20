require 'spec_helper'

describe ActivityTracker::ActivityType do
  before :each do
    ActivityTracker::ActivityTypeRepository.reset
    @instance = ActivityTracker::ActivityTypeRepository.instance
  end

  let(:activity_type) do
    ActivityTracker::ActivityType.new do
      name 'activity_type_1'
    end
  end

  describe '.instance' do
    it 'returns a repository object' do
      expect(@instance).to be_a(ActivityTracker::ActivityTypeRepository)
    end

    it 'returns the same instance every time' do
      instance1 = ActivityTracker::ActivityTypeRepository.instance
      instance2 = ActivityTracker::ActivityTypeRepository.instance

      expect(instance1).to eq(instance2)
    end
  end

  describe '.reset' do
    it 'resets the instance' do
      instance1 = ActivityTracker::ActivityTypeRepository.instance
      ActivityTracker::ActivityTypeRepository.reset
      instance2 = ActivityTracker::ActivityTypeRepository.instance

      expect(instance1).not_to eq(instance2)
    end
  end

  describe '#add' do
    it 'expects an ActivityType instance' do
      expect { @instance.add }.to raise_error(ArgumentError)
      expect { @instance.add(123) }.to raise_error(ArgumentError)
    end

    it 'replaces existing ActivityType' do
      @instance.add(activity_type)
      @instance.add(activity_type)

      expect(@instance.all.count).to eq(1)
    end
  end

  describe '#all' do
    it 'returns empty array if nothing added' do
      expect(@instance.all).to eq([])
    end
  end

  describe '#add' do
  end

  describe '#get' do
    it 'raises ArgumentError if activity type does not exist' do
      expect { @instance.get }.to raise_error(ArgumentError)
      expect { @instance.get(123) }.to raise_error(ArgumentError)
      expect { @instance.get('does-not-exist') }.to raise_error(ArgumentError)
    end

    it 'gets the instance both with string and symbol arguments' do
      @instance.add(activity_type)

      expect(@instance.get('activity_type_1')).to eq(activity_type)
      expect(@instance.get(:activity_type_1)).to eq(activity_type)
    end
  end
end
