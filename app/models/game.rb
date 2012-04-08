class Game < ActiveRecord::Base
  belongs_to :league
  belongs_to :club_home, class_name: 'Club'
  belongs_to :club_away, class_name: 'Club'

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

end
