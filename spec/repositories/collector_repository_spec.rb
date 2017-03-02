require 'spec_helper'

describe ActivityTracker::CollectorRepository do
  let(:instance) { ActivityTracker::CollectorRepository.instance }

  describe '.instance' do
    it 'returns a repository object' do
      expect(instance).to be_a(ActivityTracker::CollectorRepository)
    end
  end

  describe '#exists?' do
    it 'returns false initially' do
      expect(instance.exists?).to eq(false)
    end

    it 'returns true after calling get' do
      instance.get

      expect(instance.exists?).to eq(true)
    end

    it 'returns false after calling clear' do
      instance.get
      instance.clear

      expect(instance.exists?).to eq(false)
    end
  end
end
