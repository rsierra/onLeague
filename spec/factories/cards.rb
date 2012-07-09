# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    game { create(:game) }
    player { create(:player_in_game, player_game: game) }

    minute 1
    kind Card.kind.values.first
  end

  trait :red do
    minute 2
    kind Card.kind.values.second

    before(:create) do |card, evaluator|
      create(:card, player: card.player, game: card.game)
    end
  end

  trait :direct_red do
    kind Card.kind.values.last
  end
end
