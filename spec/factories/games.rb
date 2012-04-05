# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game do
    association :league, factory: :league
    association :club_home, factory: :club
    association :club_away, factory: :club
    date "2012-04-03 20:20:38"
    week 1
    season 2000
    status Game.status.values.first

    factory :game_with_associated_clubs do
      after_build  do |game|
        game.club_home.leagues << game.league
        game.club_away.leagues << game.league
      end
    end
  end
end
