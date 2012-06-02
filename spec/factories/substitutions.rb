# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :substitution do
    game { create(:game) }
    player_out { create(:player_with_club, player_club: game.club_home) }
    player_in { create(:player_with_club, player_club: game.club_home) }
    minute 1
  end
end
