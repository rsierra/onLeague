# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :goal do
    game { create(:game) }
    scorer { create(:player_in_game, player_game: game) }

    minute 1
    kind Goal.kind.values.first
  end
end
