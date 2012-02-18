# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oauth_provider do
    provider "MyString"
    uid "MyString"
    uname "MyString"
    uemail "MyString"
    user nil
  end
end
