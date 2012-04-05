# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :club_file do
    association :club, factory: :club
    association :player, factory: :player
    sequence(:number) { |n| n }
    position { ClubFile.position.values.first }
    value { number }
    date_in { Date.yesterday }
    date_out nil
  end
end
