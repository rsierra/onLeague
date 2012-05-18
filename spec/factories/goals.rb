# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :goal do
    ignore do
      game_league { create(:league) }
      scorer_club { create(:club, leagues: [game_league]) }
    end
    game { create(:game, league: game_league, club_home: scorer_club) }
    scorer { create(:player_with_club, player_club: scorer_club) }

    minute 1
    kind Goal.kind.values.first
  end
end
