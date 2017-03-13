FactoryGirl.define do
  factory :activity do
    association :sender, factory: :user, strategy: :build
    created_at DateTime.now
    type 'type1'
  end
end
