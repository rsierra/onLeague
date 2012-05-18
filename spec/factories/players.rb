# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    sequence(:name) { |n| "Player #{n}" }
    born 20.years.ago.to_date
    active true
    eu true
    association :country, factory: :country

    factory :player_with_club do
      ignore do
        player_club { create(:club) }
      end
      after(:create) do |player, evaluator|
        create(:club_file, player: player, club: evaluator.player_club)
      end
    end
  end
end
