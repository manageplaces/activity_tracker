FactoryGirl.define do
  factory :activity do
    association :sender, factory: :user, strategy: :build
    created_at Time.zone.now
    activity_type 'type1'
    association :scope, factory: :task, strategy: :build
  end
end
