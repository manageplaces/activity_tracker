FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "user_#{n}"
    end
  end
end
