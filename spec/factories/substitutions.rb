# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :substitution do
    game { create(:game) }
    player_out { create(:player_in_game, player_game: game) }
    player_in { create(:player_with_club, player_club: game.club_home) }
    minute 1

    factory :substitution_away do
      player_out { create(:player_in_game_away, player_game: game) }
      player_in { create(:player_with_club, player_club: game.club_away) }
    end
  end
end
