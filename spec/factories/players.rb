# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    sequence(:name) { |n| "Player #{n}" }
    born 20.years.ago.to_date
    active true
    eu true
    association :country, factory: :country
  end
end
