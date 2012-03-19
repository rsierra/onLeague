
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
  :email => "admin@mail.com",
  :password => "metadmin",
  :password_confirmation => "metadmin"
}
admin = Admin.create admin_params

(1..2).each do |n|
  league_params =
  {
    :name => "Test League #{n}",
    :week => 1,
    :season => 2000,
    :active => true
  }
  league = League.create league_params

  (1..20).each do |n|
    club_params =
    {
      :name => "#{league.name} Club #{n}",
      :short_name => "C#{n}",
      :description => <<-eos
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque vel libero tellus. Proin pharetra imperdiet felis, et feugiat sapien porta et. Praesent malesuada molestie auctor. Duis ut libero ultricies enim semper molestie id ac quam. Mauris in varius velit. Morbi sed justo viverra mi fringilla molestie. Aliquam erat volutpat. Mauris in fermentum libero. Vestibulum in sapien vel nisl suscipit lobortis. Vestibulum a egestas odio. Pellentesque convallis sodales est, non porta dolor tristique eu. Curabitur lobortis porttitor felis, nec consequat mauris vehicula vitae. Curabitur diam enim, malesuada imperdiet porttitor sed, rutrum non ipsum. Praesent eu massa lorem.
  <br/><br/>
  Ut feugiat posuere velit, at aliquam augue consectetur sed. Praesent volutpat varius est eget faucibus. Nunc congue auctor tortor, vel ultrices lacus pretium blandit. Mauris semper lacinia leo, bibendum elementum erat sollicitudin sit amet. Nulla tellus enim, egestas a lobortis nec, mattis porttitor purus. Phasellus quis venenatis ante. Nulla rutrum ullamcorper mi, sed mollis turpis cursus id. Curabitur eget metus et nunc mattis porta. Vivamus quam arcu, luctus ut mattis non, congue et justo. Vivamus ultrices mollis lorem, non tristique nisi sodales at. Phasellus mattis, elit at dignissim condimentum, sem neque placerat augue, non accumsan augue sapien sed arcu.
  eos
    }
    club = Club.create club_params
    league.clubs << club
    league.save
  end
end