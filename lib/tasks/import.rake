# Import tasks for old version aplication data
require 'csv'

namespace :onleague do
  namespace :import do
    desc "Import countries form csv"
    task :countries, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:countries[file_path]"
      else
        log = Logger.new("log/csv_import_countries.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting countries importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          country_params = {
            name: row["name"],
            created_at: row["created_at"],
            updated_at: row["updated_at"]
          }
          country = Country.create country_params
          if country.invalid?
            errors += 1
            log.info "\nError in country creation"
            log.info "Row: #{row.to_s.chomp}"
            log.info "Params: #{country_params}"
            country.errors.full_messages.each { |msg| log.info "\t#{msg}" }
          end
        end

        log.info "\n#{DateTime.now} >> Countries importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Countries importation ended successfully."
        else
          puts "Countries importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_countries.log'."
        end
      end
    end

    desc "Import clubs form csv"
    task :clubs, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:clubs[file_path]"
      else
        log = Logger.new("log/csv_import_clubs.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting clubs importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          club_params = {
            name: row["name"],
            short_name: row["short_name"],
            created_at: row["created_at"],
            updated_at: row["updated_at"],
            number_color: row["number_color"],
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
          if club.invalid?
            errors += 1
            log.info "\nError in club creation"
            log.info "Row: #{row.to_s.chomp}"
            log.info "Params: #{club_params}"
            club.errors.full_messages.each { |msg| log.info "\t#{msg}" }
          end
        end

        log.info "\n#{DateTime.now} >> Clubs importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Clubs importation ended successfully."
        else
          puts "Clubs importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_club.log'."
        end
      end
    end

    desc "Import games form csv"
    task :games, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:games[file_path]"
      else
        log = Logger.new("log/csv_import_games.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting games importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          game_params = {
            date: row["date"],
            week: row["week"],
            season: row["season"],
            club_home_id: row["club_home_id"],
            club_away_id: row["club_away_id"],
            status: row["status"],
            created_at: row["created_at"],
            updated_at: row["updated_at"],
            league_id: row["league_id"]
          }
          game = Game.create game_params
          if game.invalid?
            errors += 1
            log.info "\nError in game creation"
            log.info "Row: #{row.to_s.chomp}"
            log.info "Params: #{game_params}"
            game.errors.full_messages.each { |msg| log.info "\t#{msg}" }
          end
        end

        log.info "\n#{DateTime.now} >> Games importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Games importation ended successfully."
        else
          puts "Games importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_games.log'."
        end
      end
    end

    desc "Import players form csv"
    task :players, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:players[file_path]"
      else
        log = Logger.new("log/csv_import_players.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting players importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player_params = {
            name: row["name"],
            active: row["active"],
            country_id: row["country_id"],
            born: row["born"],
            eu: row["eu"],
            created_at: row["created_at"],
            updated_at: row["updated_at"]
          }
          player = Player.create player_params
          if player.invalid?
            errors += 1
            log.info "\nError in player creation"
            log.info "Row: #{row.to_s.chomp}"
            log.info "Params: #{player_params}"
            player.errors.full_messages.each { |msg| log.info "\t#{msg}" }
          end
        end

        log.info "\n#{DateTime.now} >> Players importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Players importation ended successfully."
        else
          puts "Players importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_players.log'."
        end
      end
    end

    desc "Import club files form csv"
    task :club_files, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:club_files[file_path]"
      else
        log = Logger.new("log/csv_import_club_files.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting club_files importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player = Player.find_by_name(row["name"])

          if player.blank?
            errors +=1
            log.info "\nPlayer #{row["name"]} not found."
          else
            club_file_params = {
              player_id: player.id,
              club_id: row["club_id"],
              value: row["value"].to_f,
              date_in: row["date_in"],
              position: row["position"],
              number: row["number"],
              created_at: row["created_at"],
              updated_at: row["updated_at"]
            }
            club_file = ClubFile.create club_file_params
            if club_file.invalid?
              errors += 1
              log.info "\nError in club_file creation"
              log.info "Row: #{row.to_s.chomp}"
              log.info "Params: #{club_file_params}"
              club_file.errors.full_messages.each { |msg| log.info "\t#{msg}" }
            end
          end
        end

        log.info "\n#{DateTime.now} >> Club files importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Club files importation ended successfully."
        else
          puts "Club files importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_club_files.log'."
        end
      end
    end

    desc "Import goals form csv"
    task :goals, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:goals[file_path]"
      else
        log = Logger.new("log/csv_import_goals.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting goals importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player = Player.find_by_name(row["scorer"])

          if player.blank?
            errors +=1
            log.info "\nPlayer #{row["scorer"]} not found."
          else
            assistant = Player.find_by_name(row["assistant"])
            goal_params = {
              game_id: row["game_id"],
              scorer_id: player.id,
              assistant_id: assistant.blank? ? nil : assistant.id,
              minute: row["minute"].to_i,
              kind: row["kind"]
            }
            goal = Goal.create goal_params
            if goal.invalid?
              errors += 1
              log.info "\nError in goal creation"
              log.info "Row: #{row.to_s.chomp}"
              log.info "Params: #{goal_params}"
              goal.errors.full_messages.each { |msg| log.info "\t#{msg}" }
            end
          end
        end

        log.info "\n#{DateTime.now} >> Goals importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Goals importation ended successfully."
        else
          puts "Goals importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_goals.log'."
        end
      end
    end
  end
end