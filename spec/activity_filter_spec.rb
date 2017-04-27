require 'spec_helper'

describe ActivityTracker::ActivityFilter do
  let(:user1) { create :user }

  let(:type1_activity) do
    {
      activity_type: :type1,
      receivers: [user1],
      property1: :value1,
      property2: :value1
    }
  end

  let(:type2_activity) do
    {
      activity_type: :type2,
      receivers: [user1],
      property1: :value2,
      property2: :value2
    }
  end

  let(:type3_activity) do
    {
      activity_type: :type3,
      receivers: [user1],
      property1: :value3
    }
  end

  let(:all_activities) { [type1_activity, type2_activity, type3_activity] }

  it 'raises error if initialized with more than 1 param' do
    expect do
      ActivityTracker::ActivityFilter.new(99, 100)
    end.to raise_error(ArgumentError)
  end

  it 'raises error if initialized with unsupported params' do
    expect do
      ActivityTracker::ActivityFilter.new(99)
    end.to raise_error(ArgumentError)
  end

  it 'matches everything if filter empty' do
    filter1 = ActivityTracker::ActivityFilter.new
    filter2 = ActivityTracker::ActivityFilter.new(true)

    all_activities.each do |activity|
      expect(filter1.match?(activity)).to eq(true)
      expect(filter2.match?(activity)).to eq(true)
    end
  end

  it 'does not match anything if filter is false' do
    filter1 = ActivityTracker::ActivityFilter.new(false)

    all_activities.each do |activity|
      expect(filter1.match?(activity)).to eq(false)
    end
  end

  it 'filters by :activity_type if passed a single type' do
    filter1 = ActivityTracker::ActivityFilter.new(:type1)
    filter2 = ActivityTracker::ActivityFilter.new([:type1])
    filter3 = ActivityTracker::ActivityFilter.new('type1')

    [filter1, filter2, filter3].each do |filter|
      expect(filter.match?(type1_activity)).to eq(true)
      expect(filter.match?(type2_activity)).to eq(false)
      expect(filter.match?(type3_activity)).to eq(false)
    end
  end

  it 'filters by :activity_type if several types passed' do
    filter1 = ActivityTracker::ActivityFilter.new([:type1, :type2])

    expect(filter1.match?(type1_activity)).to eq(true)
    expect(filter1.match?(type2_activity)).to eq(true)
    expect(filter1.match?(type3_activity)).to eq(false)
  end

  it 'filters by :activity_type if activity type is passed in hash' do
    filter1 = ActivityTracker::ActivityFilter.new(activity_type: :type1)
    filter2 = ActivityTracker::ActivityFilter.new(activity_type: [:type1, :type2])

    expect(filter1.match?(type1_activity)).to eq(true)
    expect(filter1.match?(type2_activity)).to eq(false)
    expect(filter1.match?(type3_activity)).to eq(false)

    expect(filter2.match?(type1_activity)).to eq(true)
    expect(filter2.match?(type2_activity)).to eq(true)
    expect(filter2.match?(type3_activity)).to eq(false)
  end

  it 'accepts filtering by other properties' do
    filter1 = ActivityTracker::ActivityFilter.new(property1: :value1)
    filter2 = ActivityTracker::ActivityFilter.new(property2: [:value1, :value2])

    expect(filter1.match?(type1_activity)).to eq(true)
    expect(filter1.match?(type2_activity)).to eq(false)
    expect(filter1.match?(type3_activity)).to eq(false)

    expect(filter2.match?(type1_activity)).to eq(true)
    expect(filter2.match?(type2_activity)).to eq(true)
    expect(filter2.match?(type3_activity)).to eq(false)
  end
end
