# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oauth_provider do
    provider "provider"
    uid "provider_uid"
    uname "Provider Name"
    uemail "provider@mail.com"
    user nil
  end

  factory :facebook_provider, :class => OauthProvider do
    provider "facebook"
    uid "facebook_uid"
    uname "Facebook Name"
    uemail "facebook@mail.com"
    user nil
  end

  factory :google_provider, :class => OauthProvider do
    provider "google"
    uid "google_uid"
    uname "Google Name"
    uemail "google@mail.com"
    user nil
  end

  factory :twitter_provider, :class => OauthProvider do
    provider "twitter"
    uid "twitter_uid"
    uname "Twitter Name"
    uemail nil
    user nil
  end
end
