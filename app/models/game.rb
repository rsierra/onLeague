class Game < ActiveRecord::Base
  belongs_to :league
  belongs_to :club_home, class_name: 'Club'
  belongs_to :club_away, class_name: 'Club'
  has_many :goals
  accepts_nested_attributes_for :goals

  extend FriendlyId
  friendly_id :custom_slug, use: :slugged

  include Enumerize
  enumerize :status, in: %w(active inactive evaluated closed)

  attr_reader :name

  validates :league, :club_home, :club_away, presence: true
  validates :date,  presence: true
  validates :status,  presence: true, inclusion: { in: Game.status.values }
  validates :week,  presence: true,
                    numericality: { only_integer: true, greater_than: 0 },
                    length: { minimum: 1, maximum: 2 }
  validates :season,  presence: true,
                      numericality: { only_integer: true, greater_than: 0 },
                      length: { is: 4 }
  validates :slug,  presence: true, uniqueness: true

  validate :validate_play_himself, :validate_clubs_league

  after_find :initialize_name
  after_create :initialize_name

  scope :week, ->(week) { where week: week }
  scope :season, ->(season) { where season: season }

  def initialize_name
    @name = "#{club_home.name} - #{club_away.name}"
  end

  def custom_slug
    "#{club_home.name} #{club_away.name} #{season} #{week}"
  end

  def status_enum
    Game.status.values
  end

  def play_himself?
    club_home == club_away
  end

  def validate_play_himself
    errors.add(:club_home, :cant_play_himself) if play_himself?
  end

  def club_home_play_league?
    club_home.leagues.include? league
  end

  def club_away_play_league?
    club_home.leagues.include? league
  end

  def validate_clubs_league
    errors.add(:club_home, :should_play_same_league) unless club_home_play_league?
    errors.add(:club_away, :should_play_same_league) unless club_away_play_league?
  end

  def home_goals
    goals.club(club_home).count
  end

  def away_goals
    goals.club(club_away).count
  end

  def home_players
    club_home.club_files.on(date)
  end

  def away_players
    club_away.club_files.on(date)
  end

  def end_date_of_week
    league.end_date_of_week(week,season)
  end

  def result
    "#{home_goals} - #{away_goals}"
  end

  def player_in_club_home? player
    home_players.map(&:player).include? player
  end

  def player_in_club_away? player
    away_players.map(&:player).include? player
  end
end
