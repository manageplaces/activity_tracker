FactoryGirl.define do
  factory :activity_batch do
    association :receiver, factory: :user, strategy: :build
  end
end
