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
end
