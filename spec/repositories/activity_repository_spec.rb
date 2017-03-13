require 'spec_helper'

describe ActivityTracker::ActivityType do
  let(:instance) { ActivityTracker::ActivityRepository.new }

  describe '#add' do
    it 'requires an Activity object' do
      expect { instance.add }.to raise_exception(ArgumentError)
      expect { instance.add('abc') }.to raise_exception(ArgumentError)
      expect { instance.add(222.33) }.to raise_exception(ArgumentError)
    end
  end

  describe '#all' do
    it 'returns no objects if empty' do
      expect(instance.all.count).to eq(0)
    end
  end
end
