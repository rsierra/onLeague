# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :club do
    ignore do
      sequence(:number) { |n| n }
    end

    name { "Club #{number}" }
    short_name "CLB"
    description "Description"

    factory :club_with_leagues do
      ignore do
        leagues_count 2
      end
      after(:create) do |club, evaluator|
        create_list(:league, evaluator.leagues_count, :clubs => [club])
      end
    end
  end
end
