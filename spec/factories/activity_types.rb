require 'spec_helper'

FactoryGirl.define do
  factory :activity_type, class: ::ActivityTracker::ActivityType do
    name 'test1'
  end
end
