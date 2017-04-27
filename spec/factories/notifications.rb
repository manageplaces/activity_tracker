FactoryGirl.define do
  factory :notification do
    association :activity, factory: :activity, strategy: :build
    association :notification_batch, factory: :notification_batch, strategy: :build
    send_mail true
  end
end
