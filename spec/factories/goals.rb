# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :goal do
    game { create(:game) }
    scorer { create(:player_with_club, player_club: game.club_home) }

    minute 1
    kind Goal.kind.values.first
  end
end
