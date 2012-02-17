
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

(1..20).each do |n|
  user_alias = "testuser#{n}"
  user_params =
  {
    :email => "#{user_alias}@mail.com",
    :alias => "#{user_alias}",
    :password => "#{user_alias}",
    :password_confirmation => "#{user_alias}"
  }
  user = User.new user_params
  user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
  user.save
end
