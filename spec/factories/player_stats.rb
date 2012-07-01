# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player_stat do
    player { create(:player) }
    game { create(:game) }
    points 10
    goals_scored 1
    assists 1
    goals_conceded 0
    yellow_cards 1
    red_cards 1
    lineups 1
    games_played 1
    minutes_played 90
  end
end
