# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country do
    ignore do
      sequence(:number) { |n| n }
    end

    name { "Country #{number}" }
    eu false
  end
end
