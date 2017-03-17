require 'spec_helper'

describe ActivityTracker::HasActivities do
  before :all do
    load File.dirname(__FILE__) + '/support/activity_types.rb'
  end

  specify 'client class has track_activity method mixed in' do
    t = Task.new
    users = [create(:user), create(:user)]
    expect(t.instance_eval { track_activity(users, :type1) }).to eq(nil)
  end
end
