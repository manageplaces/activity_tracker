FactoryGirl.define do
  factory :notification_batch do
    association :receiver, factory: :user, strategy: :build

    trait :old do
      created_at 1.week.ago
      last_activity 1.week.ago
    end
  end
end
