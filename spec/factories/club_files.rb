# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :club_file do
    association :club, factory: :club
    association :player, factory: :player
    sequence(:number) { |n| n }
    position { ClubFile.position.values.first }
    value { number }
    week_in { number }
    season_in { number }

    factory :club_file_with_out do
      week_out { number }
      season_out { number }
    end
  end
end
