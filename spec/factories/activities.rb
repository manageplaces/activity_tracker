FactoryGirl.define do
  factory :activity do
    association :sender, factory: :user, strategy: :build
    created_at DateTime.now
    activity_type 'type1'
    association :scope, factory: :task, strategy: :build
  end
end
