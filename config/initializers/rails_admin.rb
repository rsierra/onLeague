# RailsAdmin config file. Generated on March 02, 2012 18:04
# See github.com/sferik/rails_admin for more informations

require "rails_admin/config/actions/close_week"
require "rails_admin/config/actions/scraper_lineups"
require "rails_admin/config/actions/scrap_lineups"
require "rails_admin/config/actions/scraper_cards"
require "rails_admin/config/actions/scrap_cards"
require "rails_admin/config/actions/scraper_substitutions"
require "rails_admin/config/actions/scrap_substitutions"
require "rails_admin/config/actions/scraper_goals"
require "rails_admin/config/actions/scrap_goals"

RailsAdmin.config do |config|

  config.actions do
    dashboard
    index
    new
    show
    edit
    close_week
    scraper_lineups
    scrap_lineups
    scraper_substitutions
    scrap_substitutions
    scraper_cards
    scrap_cards
    scraper_goals
    scrap_goals
    delete
  end

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  require 'i18n'
  I18n.default_locale = :es

  config.current_user_method { current_admin } # auto-generated

  # If you want to track changes on your models:
  config.audit_with :history, Admin

  # Or with a PaperTrail: (you need to install it first)

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['onLeague', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  config.authorize_with :cancan

  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Admin, OauthProvider, User]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [User, OauthProvider, League, Club, ClubTranslation, Country, CountryTranslation, Player, ClubFile, Game, Goal, Card, Substitution, Lineup, GameMark]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end



  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  config.model OauthProvider do
    parent User
    object_label_method :provider

    # Found associations:
    configure :user, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :provider, :string
    configure :uid, :string
    configure :uname, :string
    configure :uemail, :string
    configure :user_id, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :provider
      field :user
      field :uname
      field :uemail
      field :uid

      filters [:provider, :user, :uname, :uemail]
    end
    export do; end
    show do
      field :provider
      field :user
      field :uname
      field :uemail
      field :uid
      field :created_at do
        visible true
      end
    end
    edit do; end
    create do; end
    update do; end
  end

  config.model User do
    object_label_method :name

    # Found associations:
    configure :oauth_providers, :has_many_association
    # Found columns:
    configure :id, :integer
    configure :email, :string
    configure :password, :password
    configure :password_confirmation, :password
    configure :reset_password_token, :string
    configure :reset_password_sent_at, :datetime
    configure :remember_created_at, :datetime
    configure :sign_in_count, :integer
    configure :current_sign_in_at, :datetime
    configure :last_sign_in_at, :datetime
    configure :current_sign_in_ip, :string
    configure :last_sign_in_ip, :string
    configure :confirmation_token, :string
    configure :confirmed_at, :datetime
    configure :confirmation_sent_at, :datetime
    configure :unconfirmed_email, :string
    configure :failed_attempts, :integer
    configure :unlock_token, :string
    configure :locked_at, :datetime
    configure :created_at, :datetime
    configure :updated_at, :datetime
    configure :name, :string

    # Sections:
    list do
      field :name
      field :email
      field :sign_in_count
      field :failed_attempts
      field :created_at do
        visible true
      end

      filters [:name, :email]
    end
    export do; end
    show do
      field :name
      field :email
      field :oauth_providers
      field :sign_in_count
      field :failed_attempts
      field :current_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_at
      field :last_sign_in_ip
      field :confirmed_at
      field :locked_at
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :name
      field :email
      field :password
      field :password_confirmation
    end
    create do; end
    update do; end
  end

  config.model League do
    object_label_method :name

    # Found associations:
    configure :clubs, :has_and_belongs_to_many_association
    # Found columns:
    configure :id, :integer
    configure :name, :string
    configure :week, :integer
    configure :season, :integer
    configure :active, :boolean
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :name
      field :week
      field :season
      field :active

      filters [:name]
    end
    export do; end
    show do
      field :name
      field :week
      field :season
      field :active
      field :clubs
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      include_all_fields
      exclude_fields :games
    end
    create do; end
    update do; end
  end

  config.model Club do
    object_label_method :name

    # Found associations:
    configure :leagues, :has_and_belongs_to_many_association
    configure :club_translations, :has_many_association
    configure :files, :has_many_association
    # Found columns:
    configure :id, :integer
    configure :name, :string
    configure :short_name, :string
    configure :description, :text
    configure :logo, :paperclip
    configure :jersey, :paperclip
    configure :number_color, :color
    configure :slug, :string do
      hide
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :name
      field :short_name

      filters [:name, :short_name]
    end
    export do; end
    show do
      field :name
      field :short_name
      field :logo
      field :jersey
      field :number_color
      field :leagues
      field :club_translations
      field :description
      field :files
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do; end
    create do
      field :name
      field :short_name
      field :leagues
      field :logo
      field :jersey
      field :number_color
      field :description
    end
    update do
      field :name
      field :short_name
      field :leagues
      field :logo
      field :jersey
      field :number_color
      field :club_translations
      field :files
    end
  end

  config.model ClubTranslation do
    visible false

    object_label_method :locale

    parent Club
    # Found associations:
    configure :club, :belongs_to_association
    # Found columns:
    configure :description, :text
    configure :locale, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :locale_enum
      end
    end

    # Sections:
    list do
      field :locale
      field :club

      filters [:club, :locale]
    end
    export do; end
    show do
      field :locale
      field :club
      field :description
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    create do
      field :club
      field :locale
      field :description
    end
    update do
      field :club do
        read_only true
      end
      field :locale do
        read_only true
      end
      field :description
    end

    nested do
      include_all_fields
      exclude_fields :club
    end
  end

  config.model Country do
    object_label_method :name

    # Found associations:
    configure :country_translations, :has_many_association
    # Found columns:
    configure :id, :integer
    configure :name, :string
    configure :flag, :paperclip
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :name
      field :flag

      filters [:name]
    end
    export do; end
    show do
      field :name
      field :flag
      field :country_translations
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do; end
    create do
      field :name
      field :flag
    end
    update do
      field :country_translations
      field :flag
    end
  end

  config.model CountryTranslation do
    visible false

    object_label_method :locale

    parent Country
    # Found associations:
    configure :country, :belongs_to_association
    # Found columns:
    configure :name, :string
    configure :locale, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :locale_enum
      end
    end

    # Sections:
    list do
      field :locale
      field :country

      filters [:country, :locale]
    end
    export do; end
    show do
      field :locale
      field :country
      field :name
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    create do
      field :country
      field :locale
      field :name
    end
    update do
      field :country do
        read_only true
      end
      field :locale do
        read_only true
      end
      field :name
    end
    nested do
      include_all_fields
      exclude_fields :country
    end
  end

  config.model Player do
    object_label_method :name

    # Found associations:
    configure :country, :belongs_to_association
    configure :file, :has_one_association
    configure :club, :has_one_association
    configure :club_files, :has_many_association do
      hide
    end
    configure :lineups, :has_many_association do
      hide
    end
    configure :cards, :has_many_association do
      hide
    end
    configure :yellow_cards, :has_many_association do
      hide
    end
    configure :red_cards, :has_many_association do
      hide
    end
    configure :direct_red_cards, :has_many_association do
      hide
    end
    configure :substitutions_out, :has_many_association do
      hide
    end
    configure :substitutions_in, :has_many_association do
      hide
    end
    configure :goals, :has_many_association do
      hide
    end
    configure :assists, :has_many_association do
      hide
    end
    configure :stats, :has_many_association do
      hide
    end
    # Found columns:
    configure :id, :integer
    configure :name, :string
    configure :born, :date
    configure :active, :boolean
    configure :eu, :boolean
    configure :slug, :string do
      hide
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      include_fields :name, :born, :country, :active, :club

      filters [:name, :active]
    end
    export do; end
    show do
      include_fields :name, :born, :active, :country, :eu, :active, :club, :file
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :club do
        read_only true
      end
      field :file do
        read_only true
      end
      field :name
      field :born do
        date_format :default
      end
      include_fields :country, :eu, :active
    end
    create do
      exclude_fields :club, :file
    end
    update do; end
  end

  config.model ClubFile do
    object_label_method :title

    parent Club
    # Found associations:
    configure :player, :belongs_to_association
    configure :club, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :number, :integer
    configure :position, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :position_enum
      end
      pretty_value do # used in form list
        I18n.t("enumerize.club_file.position.#{value}")
      end
    end
    configure :value, :float
    configure :date_in, :date
    configure :date_out, :date
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :club
      field :player
      field :number
      field :position
      field :value

      filters [:club]
    end
    export do; end
    show do
      field :club
      field :player
      field :number
      field :position
      field :value
      field :date_in
      field :date_out
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      include_all_fields
      field :date_in do
        date_format :default
      end
      field :date_out do
        date_format :default
      end
    end
    create do; end
    update do; end
    nested do
      field :club do
        hide
      end
      field :player do
        visible do
          bindings[:object].new_record?
        end
      end
      include_all_fields
      field :date_in do
        date_format :default
      end
      field :date_out do
        date_format :default
      end
    end
  end

  config.model Game do
    object_label_method :name

    parent League
    # Found associations:
    configure :league, :belongs_to_association
    configure :club_home, :belongs_to_association
    configure :club_away, :belongs_to_association
    configure :lineups, :has_many_association
    configure :substitutions, :has_many_association
    configure :cards, :has_many_association
    configure :goals, :has_many_association
    configure :marks, :has_many_association
    # Found columns:
    configure :id, :integer
    configure :date, :datetime
    configure :status, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :status_enum
      end
      pretty_value do # used in form list
        I18n.t("enumerize.game.status.#{value}")
      end
    end
    configure :week, :integer
    configure :season, :integer
    configure :slug, :string do
      hide
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      include_fields :club_home, :club_away, :week, :season, :status
      include_fields :date, :league

      filters [:league, :week, :season]
    end
    export do; end
    show do
      field :name
      field :league
      field :club_home
      field :club_away
      field :date
      field :status
      field :week
      field :season
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :league
      field :club_home
      field :club_away
      field :date do
        date_format :default
      end
      field :status
      field :week
      field :season
    end
    create do
      exclude_fields :status
    end
    update do
      field :lineups
      field :substitutions
      field :cards
      field :goals
      field :marks
    end
  end

  config.model Goal do
    object_label_method :title

    parent Game
    # Found associations:
    configure :game, :belongs_to_association
    configure :scorer, :belongs_to_association
    configure :assistant, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :minute, :integer
    configure :kind, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :kind_enum
      end
      pretty_value do # used in form list
        I18n.t("enumerize.goal.kind.#{value}")
      end
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :scorer
      field :assistant
      field :kind
      field :game

      filters [:scorer, :assistant, :kind]
    end
    show do
      include_all_fields
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :game do
        read_only true
      end
      include_all_fields
    end
    nested do
      field :game do
        hide
      end
      field :goalkeeper do
        read_only true
        visible do
          !bindings[:object].new_record?
        end
      end
      include_all_fields
    end
  end

  config.model Card do
    object_label_method :title

    parent Game
    # Found associations:
    configure :game, :belongs_to_association
    configure :player, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :minute, :integer
    configure :kind, :enum do
    # if your model has a method that sends back the options:
      enum_method do
        :kind_enum
      end
      pretty_value do # used in form list
        I18n.t("enumerize.card.kind.#{value}")
      end
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :player
      field :kind
      field :game

      filters [:player, :kind]
    end
    show do
      include_all_fields
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :game do
        read_only true
      end
      include_all_fields
    end
    nested do
      field :game do
        hide
      end
      include_all_fields
    end
  end

  config.model Substitution do
    object_label_method :title

    parent Game
    # Found associations:
    configure :game, :belongs_to_association
    configure :player_out, :belongs_to_association
    configure :player_in, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :minute, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :player_out
      field :player_in
      field :game

      filters [:player_out, :player_in]
    end
    show do
      include_all_fields
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :game do
        read_only true
      end
      include_all_fields
    end
    nested do
      field :game do
        hide
      end
      include_all_fields
    end
  end

  config.model Lineup do
    object_label_method :title

    parent Game
    # Found associations:
    configure :game, :belongs_to_association
    configure :player, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :player
      field :game

      filters [:player, :game]
    end
    show do
      include_all_fields
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :game do
        read_only true
      end
      include_all_fields
    end
    nested do
      field :game do
        hide
      end
      include_all_fields
    end
  end

  config.model GameMark do
    object_label_method :title

    parent Game
    # Found associations:
    configure :game, :belongs_to_association
    configure :player, :belongs_to_association
    # Found columns:
    configure :id, :integer
    configure :mark, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime

    # Sections:
    list do
      field :player
      field :game

      filters [:player, :game]
    end
    show do
      include_all_fields
      field :created_at do
        visible true
      end
      field :updated_at do
        visible true
      end
    end
    edit do
      field :game do
        read_only true
      end
      include_all_fields
    end
    nested do
      field :game do
        hide
      end
      include_all_fields
    end
  end
end
