FactoryGirl.define do
  factory :task do
    sequence :name do |n|
      "name_#{n}"
    end
  end
end
