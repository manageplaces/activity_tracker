FactoryGirl.define do
  factory :activity_batch do
    association :reciever, factory: :user, strategy: :build
  end
end
