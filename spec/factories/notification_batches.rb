FactoryGirl.define do
  factory :notification_batch do
    association :receiver, factory: :user, strategy: :build
  end
end
