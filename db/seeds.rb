
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
    email: "#{user_name}@mail.com",
    name: "#{user_name}",
    password: "#{user_name}",
    password_confirmation: "#{user_name}"
  }
  user = User.new user_params
  user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
  user.save
end

admin_params =
{
  email: "admin@mail.com",
  password: "metadmin",
  password_confirmation: "metadmin"
}
admin = Admin.create admin_params

(1..2).each do |n|
  league_params =
  {
    name: "Test League #{n}",
    week: 1,
    season: 2012,
    active: true
  }
  league = League.create league_params

  country_params =
  {
    name: "Country L#{league.id}"
  }
  country = Country.create country_params

  (1..20).each do |n|
    club_params =
    {
      name: "Club #{n} L#{league.id}",
      short_name: "C#{n}",
      description: <<-eos
<dl>
<dt><strong>Fundado:</strong></dt>
<dd>1900</dd>
<dt><strong>Estadio:</strong></dt>
<dd>Gran Estadio</dd>
<dt><strong>Capacidad:</strong></dt>
<dd>80.000</dd>
<dt><strong>Presidente:</strong></dt>
<dd>Presidencio perez</dd>
<dt><strong>Entrenador:</strong></dt>
<dd>Entrenancio Gonzalez</dd>
</dl>
<p>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque vel libero tellus. Proin pharetra imperdiet felis, et feugiat sapien porta et. Praesent malesuada molestie auctor. Duis ut libero ultricies enim semper molestie id ac quam. Mauris in varius velit. Morbi sed justo viverra mi fringilla molestie. Aliquam erat volutpat. Mauris in fermentum libero. Vestibulum in sapien vel nisl suscipit lobortis. Vestibulum a egestas odio. Pellentesque convallis sodales est, non porta dolor tristique eu. Curabitur lobortis porttitor felis, nec consequat mauris vehicula vitae. Curabitur diam enim, malesuada imperdiet porttitor sed, rutrum non ipsum. Praesent eu massa lorem.
</p>
eos
    }
    club = Club.create club_params
    description_en = <<-eos
<dl>
<dt><strong>Founded:</strong></dt>
<dd>1900</dd>
<dt><strong>Stadium:</strong></dt>
<dd>Gran Estadio</dd>
<dt><strong>Capacity:</strong></dt>
<dd>80.000</dd>
<dt><strong>President:</strong></dt>
<dd>Presidencio perez</dd>
<dt><strong>Coach:</strong></dt>
<dd>Entrenancio Gonzalez</dd>
</dl>
<p>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque vel libero tellus. Proin pharetra imperdiet felis, et feugiat sapien porta et. Praesent malesuada molestie auctor. Duis ut libero ultricies enim semper molestie id ac quam. Mauris in varius velit. Morbi sed justo viverra mi fringilla molestie. Aliquam erat volutpat. Mauris in fermentum libero. Vestibulum in sapien vel nisl suscipit lobortis. Vestibulum a egestas odio. Pellentesque convallis sodales est, non porta dolor tristique eu. Curabitur lobortis porttitor felis, nec consequat mauris vehicula vitae. Curabitur diam enim, malesuada imperdiet porttitor sed, rutrum non ipsum. Praesent eu massa lorem.
</p>
eos
    club.club_translations.find_by_locale(:en).update_attributes(description: description_en)
    league.clubs << club
    league.save

    (1..20).each do |n|
      player_params =
      {
        name: "Player #{n} C#{club.id}",
        born: Date.today - 20.years,
        active: true,
        eu: true,
        country_id: country.id
      }
      player = Player.create player_params

      club_file_params =
      {
        player_id: player.id,
        value: 20,
        number: n,
        position: ClubFile.position.values.last,
        date_in: Date.yesterday
      }
      club.files.create club_file_params
    end
  end
end

League.all.each do |league|
  clubs = league.clubs
  game_club = clubs.first
  week = 0
  day = 0
  clubs.drop(1).each do |club|
    week += 1
    day += 1
    game_params = {
      league_id: league.id,
      club_home_id: game_club.id,
      club_away_id: club.id,
      date: "#{league.season}-01-#{day} 22:00:00",
      week: week,
      season: league.season,
      status: Game.status.values.first
    }
    game = Game.create game_params
  end

  day = 0
  clubs.drop(1).each do |club|
    week += 1
    day += 1
    game_params = {
      league_id: league.id,
      club_home_id: club.id,
      club_away_id: game_club.id,
      date: "#{league.season}-02-#{day} 22:00:00",
      week: week,
      season: league.season,
      status: Game.status.values.first
    }
    game = Game.create game_params
  end
end
