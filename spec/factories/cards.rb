# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    game { create(:game) }
    player { create(:player_in_game, player_game: game) }

    minute 1
    kind Card.kind.values.first

    factory :red_card do
      kind Card.kind.values.last
    end
  end
end
