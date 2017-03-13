FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "name_#{n}"
    end
  end
end
