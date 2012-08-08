# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game_mark do
    game { create(:game) }
    player { create(:player_with_club, player_club: game.club_home) }
    mark 1
  end
end
