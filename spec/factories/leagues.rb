# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :league do
    sequence :name do |n|
      "League #{n}"
    end
    week 1
    season 1111
  end
end
