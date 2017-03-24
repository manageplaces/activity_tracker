require 'spec_helper'

FactoryGirl.define do
  factory :notification_setting do
    association :user, factory: :user, strategy: :build
    activity_type :type1
    level 1
  end
end
