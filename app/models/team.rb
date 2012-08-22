class Team < ActiveRecord::Base
  MAX_TEAMS = 2
  INITIAL_MONEY = 200

  belongs_to :user
  belongs_to :league

  has_many :team_files
  has_many :files, :class_name => 'TeamFile', :conditions => 'date_out is null'

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

  validate :max_per_user, unless: 'user_id.blank? || league_id.blank?'

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

  def remaining_money
    money - files.sum(:value)
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

  def remaining_files
    TeamFile::MAX_FILES - files.count
  end

  def remaining_files?
    !remaining_files.zero?
  end

  def players_in_positon position
    files.where(position: position)
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
    goalkeepers.count
  end

  def defenders_count
    defenders.count
  end

  def midfielders_count
    midfielders.count
  end

  def forwards_count
    forwards.count
  end

  def formation
    "#{defenders_count}-#{midfielders_count}-#{forwards_count}"
  end

  private

  def max_per_user
    errors.add(:user, :cant_have_more) if user.teams.of_league_season(league).count >= MAX_TEAMS
  end
end
