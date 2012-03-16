
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

(1..10).each do |n|
  user_name = "testuser#{n}"
  user_params =
  {
    :email => "#{user_name}@mail.com",
    :name => "#{user_name}",
    :password => "#{user_name}",
    :password_confirmation => "#{user_name}"
  }
  user = User.new user_params
  user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
  user.save
end

admin_params =
{
  :email => "amin@mail.com",
  :password => "metadmin",
  :password_confirmation => "metadmin"
}
admin = Admin.create admin_params

league_params =
{
  :name => "Test League",
  :week => 1,
  :season => 2000
}
league = League.create league_params