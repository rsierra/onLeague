class Game < ActiveRecord::Base
  STATUS_TYPES = %w(active inactive evaluated revised closed)

  STATUS_TRANSITIONS = {
    'active' => ['evaluated','inactive'],
    'inactive' => ['active'],
    'evaluated' => ['revised','active'],
    'revised' => ['closed','evaluated'],
    'closed' => ['revised']
    }.freeze

  belongs_to :league
  belongs_to :club_home, class_name: 'Club'
  belongs_to :club_away, class_name: 'Club'
  has_many :lineups
  accepts_nested_attributes_for :lineups
  has_many :goals
  accepts_nested_attributes_for :goals
  has_many :cards
  accepts_nested_attributes_for :cards
  has_many :substitutions
  accepts_nested_attributes_for :substitutions

  extend FriendlyId
  friendly_id :custom_slug, use: :slugged

  include Enumerize
  enumerize :status, in: STATUS_TYPES

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
  validate :initial_status, if: 'new_record? && !status.blank?'
  validate :new_status, if: 'status_changed? && !new_record?'

  scope :week, ->(week) { where week: week }
  scope :season, ->(season) { where season: season }

  def name
    "#{club_home.name} - #{club_away.name}" unless club_home.blank? || club_away.blank?
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
    goals.where(scorer_id: home_players.map(&:id)).count
  end

  def away_goals
    goals.where(scorer_id: away_players.map(&:id)).count
  end

  def home_club_files
    club_home.club_files.on(date)
  end

  def away_club_files
    club_away.club_files.on(date)
  end

  def home_players
    home_club_files.map(&:player)
  end

  def away_players
    away_club_files.map(&:player)
  end

  def end_date_of_week
    league.end_date_of_week(week,season)
  end

  def result
    status.closed? ? "#{home_goals} - #{away_goals}" : "-"
  end

  def player_in_club_home? player
    home_players.include? player
  end

  def player_in_club_away? player
    away_players.include? player
  end

  def goalkeeper_in_club_id_on_minute(club_id, minute)
    club = club_id == club_home_id ? club_home : club_away
    club_goalkeeper_ids = club.player_ids_in_position_on_date('goalkeeper',date)
    goalkeeper_lineup = lineups.of_players(club_goalkeeper_ids).first
    goalkeeper = nil
    unless goalkeeper_lineup.blank?
      goalkeeper = goalkeeper_lineup.player
      goalkeeper_substitution = substitutions.of_players_in(club_goalkeeper_ids).before(minute).last
      goalkeeper = goalkeeper_substitution.player_in unless goalkeeper_substitution.blank?
      goalkeeper = nil if goalkeeper.cards.red.before(minute).exists?
    end
    goalkeeper
  end

  def goalkeeper_against_club_id_on_minute(against_club_id, minute)
    club_id = against_club_id == club_home_id ? club_away_id : club_home_id
    goalkeeper_in_club_id_on_minute(club_id, minute)
  end

  def accepted_statuses(status)
    STATUS_TRANSITIONS[status] || []
  end

  def initial_status?
    status.active? || status.inactive?
  end

  def initial_status
    errors.add(:status, :should_be_initial_status) unless initial_status?
  end

  def new_status
    errors.add(:status, :should_be_an_accepted_status) unless accepted_statuses(status_was).include? status
  end
end
