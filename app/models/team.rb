# encoding: UTF-8

class Team < ActiveRecord::Base
  MAX_TEAMS = 2
  INITIAL_MONEY = 200
  WEEK_CHANGES = 3
  MAX_FILES = 11
  MAX_FILES_PER_CLUB = 3
  MAX_FILES_NO_EU = 3
  POSITION_LIMITS = {
    'goalkeeper'  =>  { minimum: 1, maximum: 1 },
    'defender'    =>  { minimum: 3, maximum: 5 },
    'midfielder'  =>  { minimum: 3, maximum: 4 },
    'forward'     =>  { minimum: 1, maximum: 3 }
  }

  attr_accessor :file_cart

  belongs_to :user
  belongs_to :league

  has_many :team_files
  has_many :files, class_name: 'TeamFile', conditions: 'date_out is null'
  has_many :players, through: :files

  attr_accessible :name, :active, :activation_week

  extend FriendlyId
  friendly_id :custom_slug, use: :slugged

  validates :user,  presence: true
  validates :league,  presence: true
  validates :name,  presence: true, uniqueness: { scope: [:league_id, :season] },
                    length: { minimum: 3, maximum: 25 }
  validates :money,  presence: true
  validates :activation_week, numericality: { only_integer: true, greater_than: 0 },
                    length: { minimum: 1, maximum: 2 }, unless: 'activation_week.blank?'
  validates :season,  presence: true,
                      numericality: { only_integer: true, greater_than: 0 },
                      length: { is: 4 }

  self::SQL_ATTRIBUTES = self.attribute_names.map{ |attr| "#{self.table_name}.#{attr}"}.join(',')
  self::SQL_JOINS = "LEFT OUTER JOIN team_files ON team_files.team_id = teams.id " +
    "LEFT OUTER JOIN player_stats ON team_files.player_id = player_stats.player_id " +
    "INNER JOIN games ON player_stats.game_id = games.id " +
    "AND games.week >= teams.activation_week " +
    "AND games.date >= team_files.date_in " +
    "AND games.date <= COALESCE(team_files.date_out,NOW()) "
  scope :with_points, joins(self::SQL_JOINS)
        .select("#{self::SQL_ATTRIBUTES}, COALESCE(sum(player_stats.points),0) as points")
        .group(self::SQL_ATTRIBUTES)
  scope :with_points_on_season, ->(season) {
        with_points
        .where(["games.season = ? OR games.season IS NULL",season])
      }
  scope :with_points_on_season_week, ->(season, week) {
        with_points_on_season(season)
        .where(["games.week = ? OR games.week IS NULL",week])
      }
  scope :order_by_points_on_season, ->(season) {
        with_points_on_season(season)
        .order("COALESCE(sum(player_stats.points),0) DESC")
      }
  scope :order_by_points_on_season_week, ->(season,week) {
        order_by_points_on_season(season)
        .where(["games.week = ? OR games.week IS NULL",week])
      }

  validate :max_per_user, on: :create, unless: 'user_id.blank? || league_id.blank?'
  validate :activation, if: 'active'

  scope :of_league, ->(league) { where(league_id: league) }
  scope :of_league_season, ->(league, season = league.season) { where(league_id: league, season: season) }

  before_validation :initial_values, unless: 'league.blank?'

  def initial_values
    self.money ||= INITIAL_MONEY
    self.season ||= self.league.season
  end

  def custom_slug
    "#{name} #{league.name} #{league.season}" unless league.blank?
  end

  def sale_ids
    file_cart.blank? ? [0] : file_cart.sale_ids
  end

  def current_files
    files.exclude_ids(sale_ids)
  end

  def current_players
    current_files.includes(:player).map(&:player)
  end

  def buy_files
    file_cart.blank? ? ClubFile.limit(0) : file_cart.buy_files
  end

  def sale_files
    file_cart.blank? ? ClubFile.limit(0) : file_cart.sale_files
  end

  def sale_players
    sale_files.includes(:player).map(&:player)
  end

  def buy_money
    buy_files.sum(:value)
  end

  def remaining_money
    money - current_files.sum(:value) - buy_money
  end

  def remaining_money_million
    remaining_money * 1000000
  end

  def real_value
    ClubFile.current.of_players(files.map(&:player_id)).sum(:value)
  end

  def real_value_million
    real_value * 1000000
  end

  def activate
    update_attributes(active: true, activation_week: league.week)
  end

  def could_activate?
    could = true
    could &&= files.count == MAX_FILES
    TeamFile.position.values.each do |position|
      could &&= players_in_positon(position).count >= POSITION_LIMITS[position][:minimum]
      could &&= players_in_positon(position).count <= POSITION_LIMITS[position][:maximum]
    end
    could
  end

  def remaining_files
    MAX_FILES - current_files.count - buy_files.count
  end

  def remaining_files?
    !remaining_files.zero?
  end

  def players_in_positon position
    current_files.where(position: position)
  end

  def goalkeepers
    players_in_positon :goalkeeper
  end

  def defenders
    players_in_positon :defender
  end

  def midfielders
    players_in_positon :midfielder
  end

  def forwards
    players_in_positon :forward
  end

  def goalkeepers_count
    goalkeepers.count + buy_files.where(position: :goalkeeper).count
  end

  def defenders_count
    defenders.count + buy_files.where(position: :defender).count
  end

  def midfielders_count
    midfielders.count + buy_files.where(position: :midfielder).count
  end

  def forwards_count
    forwards.count + buy_files.where(position: :forward).count
  end

  def files_by_position
    goalkeepers + defenders + midfielders + forwards
  end

  def formation
    "#{defenders_count}-#{midfielders_count}-#{forwards_count}"
  end

  def remaining_goalkeepers
    remaining_position 'goalkeeper'
  end

  def remaining_defenders
    remaining_position 'defender'
  end

  def remaining_midfielders
    remaining_position 'midfielder'
  end

  def remaining_forwards
    remaining_position 'forward'
  end

  def current_players_in_position_count position
    players_in_positon(position).count + buy_files.where(position: position).count
  end

  def remaining_position position
    POSITION_LIMITS[position][:maximum] - current_players_in_position_count(position)
  end

  def needed_position position
    needed = POSITION_LIMITS[position][:minimum] - current_players_in_position_count(position)
    needed > 0 ? needed : 0
  end

  def remaining_position? position
     current_players_in_position_count(position) < POSITION_LIMITS[position][:maximum]
  end

  def enough_money? value
    remaining_money >= value.to_f
  end

  def remaining_club? club
    current_files.where(club_id: club).count + buy_files.where(club_id: club).count < MAX_FILES_PER_CLUB
  end

  def remaining_no_eu?
    current_files.no_eu.count + buy_files.no_eu.count < MAX_FILES_NO_EU
  end

  def valid_minimums? currrent_position
    valid_minimums = true
    current_remaining_files = remaining_files
    TeamFile.position.values.each do |position|
      valid_minimums &&= (current_remaining_files - (currrent_position == position ? 0 : 1) >= needed_position(position))
    end
    valid_minimums
  end

  def remaining_changes
    Team::WEEK_CHANGES - team_files.closed_after(league.end_date_of_week(league.week - 1)).count - sale_files.count
  end

  def remaining_changes?
    !remaining_changes.zero?
  end

  def player_not_buyable_reasons player_file
    reasons = []
    reasons << I18n.t('teams.not_buyable_reasons.not_enough_money') unless enough_money?(player_file.value)
    reasons << I18n.t('teams.not_buyable_reasons.not_remaining_files') unless remaining_files?
    reasons << I18n.t('teams.not_buyable_reasons.not_remaining_positions', position: player_file.position.text.pluralize.downcase) unless remaining_position?(player_file.position)
    reasons << I18n.t('teams.not_buyable_reasons.not_remaining_clubs', club: player_file.club_name.capitalize) unless remaining_club? player_file.club
    reasons << I18n.t('teams.not_buyable_reasons.not_remaining_no_eu') unless player_file.player.eu || remaining_no_eu?
    reasons << I18n.t('teams.not_buyable_reasons.already_in_team') if current_players.include? player_file.player
    reasons << I18n.t('teams.not_buyable_reasons.already_played') if player_file.player.played_on_league? league
    reasons << I18n.t('teams.not_buyable_reasons.already_sold') if sale_players.include? player_file.player
    reasons << I18n.t('teams.not_buyable_reasons.already_buyed') if buy_files.include? player_file
    reasons << I18n.t('teams.not_buyable_reasons.invalid_minimums') unless valid_minimums? player_file.position
    reasons
  end

  def player_not_salable_reasons player_file
    reasons = []
    reasons << I18n.t('teams.not_salable_reasons.already_played') if player_file.player.played_on_league? league
    reasons << I18n.t('teams.not_salable_reasons.not_remaining_changes') unless remaining_changes?
    reasons
  end

  def checkout_cart
    message = nil
    begin
      TeamFile.transaction do
        sale_files.each { |file| file.update_attributes!(date_out: Date.today) }
        buy_files.each { |file| files.create!(file.attributes_for_team_file) }
      end
      return nil
    rescue Exception => e
      return e.message
    end
  end

  private

  def max_per_user
    errors.add(:user, :cant_have_more) if user.teams.of_league_season(league).count >= MAX_TEAMS
  end

  def activation
    errors.add(:active, :cant_activate) unless could_activate?
  end
end
