# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team_file do
    ignore do
      sequence(:number) { |n| n % 99 }
    end
    association :team, factory: :team
    association :player, factory: :player
    position 'midfielder'
    value { number }
    date_in { Date.yesterday }
    date_out nil
  end
end
