# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    game { create(:game) }
    player { create(:player_with_club, player_club: game.club_home) }

    minute 1
    kind Card.kind.values.first

    factory :red_card do
      red kind Card.kind.values.last
    end
  end
end
