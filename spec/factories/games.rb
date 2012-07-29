# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game do
    league { create(:league) }
    club_home { create(:club, leagues: [league]) }
    club_away { create(:club, leagues: [league]) }
    date Date.today
    week { league.week }
    season { league.season }
    status Game.status.values.first

    factory :game_from_club_home do
      club_home { create(:club) }
      league { club_home.leagues.first }
      club_away { create(:club, leagues: [league]) }
    end
  end

  trait :full_of_lineups do
    ignore do
      home_lineups Lineup.max_per_game
      away_lineups Lineup.max_per_game
    end
    after(:create) do |game, evaluator|
      create_list(:player_in_game, evaluator.home_lineups, player_game: game)
      create_list(:player_in_game_away, evaluator.away_lineups, player_game: game)
    end
  end
end
