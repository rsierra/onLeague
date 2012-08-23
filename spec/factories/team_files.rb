# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team_file do
    association :team, factory: :team
    association :player, factory: :player
    association :club, factory: :club
    position 'midfielder'
    value 1
    date_in { Date.yesterday }
    date_out nil

    after(:build) { |team_file| team_file.player.stub(:played?).and_return(false) }
  end
end
