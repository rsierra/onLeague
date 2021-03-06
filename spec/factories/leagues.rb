# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :league do
    sequence(:name) { |n| "League #{n}" }
    week 1
    season 1111
    active true

    factory :league_with_clubs do
      ignore do
        clubs_count 20
      end
      after(:create) do |league, evaluator|
        create_list(:club, evaluator.clubs_count, :leagues => [league])
      end
    end
  end
end
