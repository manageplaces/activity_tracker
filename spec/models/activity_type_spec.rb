require 'spec_helper'

describe ActivityTracker::ActivityType do
  describe 'initializer' do
    specify 'init with hash' do
      obj = ActivityTracker::ActivityType.new(name: 'test1')
      expect(obj).to be_a(ActivityTracker::ActivityType)
      expect(obj.name).to eq('test1')
    end

    specify 'without params' do
      obj = ActivityTracker::ActivityType.new

      expect(obj).to be_a(ActivityTracker::ActivityType)
      expect(obj.name).to be_nil
    end

    specify 'with block' do
      obj = ActivityTracker::ActivityType.new do
        name 'test2'
      end

      expect(obj.name).to eq(:test2)
    end
  end

  describe 'accessors' do
    it 'gets attribute values' do
      obj = ActivityTracker::ActivityType.new(name: 'test1')
      expect(obj.name).to eq('test1')
    end

    it 'does not allow modifying the object' do
      obj = ActivityTracker::ActivityType.new
      expect { obj.name 'test' }.to raise_exception(RuntimeError)
    end
  end
end
