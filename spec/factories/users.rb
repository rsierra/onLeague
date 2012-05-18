# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name                   "Test User"
    email                  "user@mail.com"
    password               "password"
    password_confirmation  "password"

    after(:build)  { |user| user.skip_confirmation! }

    factory :user_with_facebook do
      after(:create) do |user|
        create(:facebook_provider, :user => user)
      end
    end

    factory :user_with_google do
      after(:create) do |user|
        create(:google_provider, :user => user)
      end
    end

    factory :user_with_twitter do
      after(:create) do |user|
        create(:twitter_provider, :user => user)
      end
    end
  end
end
