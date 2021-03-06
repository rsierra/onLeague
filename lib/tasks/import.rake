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

        log.info "\nCountries importation ended with #{errors} errors."
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

        log.info "\nClubs importation ended with #{errors} errors."
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

        log.info "\nGames importation ended with #{errors} errors."
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

        log.info "\nPlayers importation ended with #{errors} errors."
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

        log.info "\nClubs importation ended with #{errors} errors."
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
            log.info "\nScorer #{row["scorer"]} not found."
            log.info "Row: #{row.to_s.chomp}"
          else
            assistant_name = row["assistant"]
            assistant = Player.find_by_name(assistant_name)
            if !assistant_name.blank? && assistant.blank?
              errors +=1
              log.info "\nAssistant #{assistant_name} not found."
              log.info "Row: #{row.to_s.chomp}"
            else
              goal_params = {
                game_id: row["game_id"],
                scorer_id: player.id,
                assistant_id: assistant_name.blank? ? nil : assistant.id,
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
        end

        log.info "\nGoals importation ended with #{errors} errors."
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

    desc "Import cards form csv"
    task :cards, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:cards[file_path]"
      else
        log = Logger.new("log/csv_import_cards.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting cards importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player = Player.find_by_name(row["player"])

          if player.blank?
            errors +=1
            log.info "\nPlayer #{row["player"]} not found."
            log.info "Row: #{row.to_s.chomp}"
          else
            card_params = {
              game_id: row["game_id"],
              player_id: player.id,
              minute: row["minute"].to_i,
              kind: row["kind"]
            }
            card = Card.create card_params
            if card.invalid?
              errors += 1
              log.info "\nError in card creation"
              log.info "Row: #{row.to_s.chomp}"
              log.info "Params: #{card_params}"
              card.errors.full_messages.each { |msg| log.info "\t#{msg}" }
            end
          end
        end

        log.info "\nCards importation ended with #{errors} errors."
        log.info "\n#{DateTime.now} >> Cards importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Cards importation ended successfully."
        else
          puts "Cards importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_cards.log'."
        end
      end
    end

    desc "Import substitutions form csv"
    task :substitutions, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:substitutions[file_path]"
      else
        log = Logger.new("log/csv_import_substitutions.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting substitutions importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player_out = Player.find_by_name(row["player_out"])

          if player_out.blank?
            errors +=1
            log.info "\nPlayer out #{row["player_out"]} not found."
            log.info "Row: #{row.to_s.chomp}"
          else
            player_in = Player.find_by_name(row["player_in"])
            if player_in.blank?
              errors +=1
              log.info "\nPlayer in #{row["player_in"]} not found."
              log.info "Row: #{row.to_s.chomp}"
            else
              substitution_params = {
                game_id: row["game_id"],
                player_out_id: player_out.id,
                player_in_id: player_in.id,
                minute: row["minute"].to_i
              }
              substitution = Substitution.create substitution_params
              if substitution.invalid?
                errors += 1
                log.info "\nError in substitution creation"
                log.info "Row: #{row.to_s.chomp}"
                log.info "Params: #{substitution_params}"
                substitution.errors.full_messages.each { |msg| log.info "\t#{msg}" }
              end
            end
          end
        end

        log.info "\nSubstitutions importation ended with #{errors} errors."
        log.info "\n#{DateTime.now} >> Substitutions importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Substitutions importation ended successfully."
        else
          puts "Substitutions importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_cards.log'."
        end
      end
    end

    desc "Import lineups form csv"
    task :lineups, [:file_path] => :environment do |t, args|
      if args.file_path.blank?
        puts "This rake task need a valid file path to import."
        puts "USE: rake onleague:import:lineups[file_path]"
      else
        log = Logger.new("log/csv_import_lineups.log")
        log.info "\n----------------------------------------------------------"
        log.info "#{DateTime.now} >> Starting lineups importation process"
        errors = 0
        CSV.foreach(args.file_path, headers: :first_row) do |row|
          player = Player.find_by_name(row["player"])

          if player.blank?
            errors +=1
            log.info "\nPlayer #{row["player"]} not found."
            log.info "Row: #{row.to_s.chomp}"
          else
            lineup_params = {
              game_id: row["game_id"],
              player_id: player.id
            }
            lineup = Lineup.create lineup_params
            if lineup.invalid?
              errors += 1
              log.info "\nError in lineup creation"
              log.info "Row: #{row.to_s.chomp}"
              log.info "Params: #{lineup_params}"
              lineup.errors.full_messages.each { |msg| log.info "\t#{msg}" }
            end
          end
        end

        log.info "\nLineups importation ended with #{errors} errors."
        log.info "\n#{DateTime.now} >> Lineups importation process ended"
        log.info "----------------------------------------------------------\n"

        if errors.zero?
          puts "Lineups importation ended successfully."
        else
          puts "Lineups importation ended with #{errors} errors."
          puts "Take a look on errors in log file 'csv_import_lineups.log'."
        end
      end
    end
  end
end