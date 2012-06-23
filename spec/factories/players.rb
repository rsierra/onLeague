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

    factory :player_in_game do
      ignore do
        player_game { create(:game) }
      end
      after(:create) do |player, evaluator|
        create(:club_file, player: player, club: evaluator.player_game.club_home)
        create(:lineup, game: evaluator.player_game, player: player)
      end
    end

    factory :player_in_game_away do
      ignore do
        player_game { create(:game) }
      end
      after(:create) do |player, evaluator|
        create(:club_file, player: player, club: evaluator.player_game.club_away)
        create(:lineup, game: evaluator.player_game, player: player)
      end
    end
  end
end
