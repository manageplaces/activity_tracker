FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "user_#{n}"
    end

    trait(:skip_notifications) { skip_notifications true }
  end
end
