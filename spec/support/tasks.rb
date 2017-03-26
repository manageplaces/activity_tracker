FactoryGirl.define do
  factory :task do
    sequence :name do |n|
      "task_#{n}"
    end
  end
end
