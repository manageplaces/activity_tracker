require 'spec_helper'

describe ActivityTracker::NotificationSettingRepository do
  let(:instance) { ActivityTracker::NotificationSettingRepository.new }

  describe '#add' do
    it 'requires a NotificationSetting object' do
      expect { instance.add }.to raise_exception(ArgumentError)
      expect { instance.add('abc') }.to raise_exception(ArgumentError)
      expect { instance.add(222.33) }.to raise_exception(ArgumentError)
    end

    it 'saves the activity' do
      notification_setting = build :notification_setting

      expect(instance.add(notification_setting)).to eq(true)
      expect(instance.all.count).to eq(1)
    end
  end

  describe '#all' do
    it 'returns no objects if empty' do
      expect(instance.all.count).to eq(0)
    end
  end
end
