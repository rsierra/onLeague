# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    ignore do
      sequence(:number) { |n| n }
    end

    user { create(:user) }
    league { create(:league) }

    activation_week nil
    name { "Team #{number}" }
  end
end
