class Game < ActiveRecord::Base
  STATUS_TYPES = %w(active inactive evaluated revised closed)
  TIME_BEFORE = 30.minutes
  TIME_AFTER = 120.minutes

  STATUS_TRANSITIONS = {
    'active' => ['evaluated','inactive'],
    'inactive' => ['active'],
    'evaluated' => ['revised','active'],
    'revised' => ['closed','evaluated'],
    'closed' => []
    }.freeze

  STATUS_EVENTS = {
    'active' => { 'evaluated' => 'update_players_stats'},
    'evaluated' => { 'active' => 'restore_players_stats'},
    }.freeze

  WINNER_STAT = { points: 1 }
  UNBEATEN_GOALKEEPER_STAT = { points: 2 }
  BEATEN_GOALKEEPER_STAT = { points: 1 }
  UNBEATEN_DEFENDER_STAT = { points: 1 }

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
  has_many :marks, class_name: 'GameMark'
  accepts_nested_attributes_for :marks

  extend FriendlyId
  friendly_id :custom_slug, use: :slugged

  include Enumerize
  enumerize :status, in: STATUS_TYPES, default: 'active'

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
  validate :number_of_lineups, if: '!status.blank? && status.evaluated?'

  scope :week, ->(week) { where week: week }
  scope :season, ->(season) { where season: season }
  scope :not_closeables, where("status = 'active' OR status = 'evaluated'")
  scope :evaluated, where(status: %w(evaluated revised closed))
  scope :of_club, ->(club_id) { where(["games.club_home_id = ? OR games.club_away_id = ?", club_id, club_id])}
  scope :on_league, ->(league_id) { where(league_id: league_id) }
  scope :playing, ->(time = Time.now) { where(date: (time - TIME_AFTER)..(time + TIME_BEFORE))}
  scope :last_week, joins("INNER JOIN leagues ON leagues.id = games.league_id AND leagues.season = games.season AND leagues.week - 1 = games.week")
  scope :next_week, joins("INNER JOIN leagues ON leagues.id = games.league_id AND leagues.season = games.season AND leagues.week + 1 = games.week")
  scope :current_week, joins("INNER JOIN leagues ON leagues.id = games.league_id AND leagues.season = games.season AND leagues.week = games.week")
  scope :played, ->(time = Time.now) {
        current_week
        .where(["games.date <= ?",time + TIME_BEFORE]) }

  before_save :trigger_status_events  , if: 'status_changed? && !new_record?'

  def name
    "#{club_home.name} - #{club_away.name}" unless club_home.blank? || club_away.blank?
  end

  def custom_slug
    "#{club_home.name} #{club_away.name} #{season} #{week}"
  end

  def status_enum
    Game.status.values
  end

  def season_name
    "#{Game.human_attribute_name(:season)} #{season}"
  end

  def week_name
    "#{Game.human_attribute_name(:week)} #{week}"
  end

  def play_himself?
    club_home == club_away
  end

  def club_home_play_league?
    club_home.leagues.include? league
  end

  def club_away_play_league?
    club_home.leagues.include? league
  end

  def home_lineups_files
    files_from home_lineups_players
  end

  def away_lineups_files
    files_from away_lineups_players
  end

  def home_substitutions_files_in
    files_from home_substitutions_players_in
  end

  def away_substitutions_files_in
    files_from away_substitutions_players_in
  end

  def files_from players
    ClubFile.of(players).on(date).order(:number).with_points_on_season_week(season,week)
  end

  def home_lineups_players
    players_from home_lineups
  end

  def away_lineups_players
    players_from away_lineups
  end

  def home_substitutions_players_in
    players_from home_substitutions, :player_in
  end

  def away_substitutions_players_in
    players_from away_substitutions, :player_in
  end

  def players_from events, player_kind = :player
    events.includes(player_kind).map(&player_kind)
  end

  def home_lineups
    home_events_from lineups
  end

  def away_lineups
    away_events_from lineups
  end

  def home_substitutions
    home_events_from substitutions
  end

  def away_substitutions
    away_events_from substitutions
  end

  def home_events_from events
    events.of_players(club_home.player_ids_on_date(date))
  end

  def away_events_from events
    events.of_players(club_away.player_ids_on_date(date))
  end

  def events
    game_events = substitutions + cards + goals
    game_events.sort {|x,y| x.minute <=> y.minute }
  end

  def home_goals
    goals.scored.of_scorers(club_home.player_ids_on_date(date)).count +
    goals.owned.of_scorers(club_away.player_ids_on_date(date)).count
  end

  def away_goals
    goals.scored.of_scorers(club_away.player_ids_on_date(date)).count +
    goals.owned.of_scorers(club_home.player_ids_on_date(date)).count
  end

  def winner_club
    calculated_home_goals = home_goals
    calculated_away_goals = away_goals
    if calculated_home_goals > calculated_away_goals
      club_home
    elsif calculated_home_goals < calculated_away_goals
      club_away
    else
      nil
    end
  end

  def end_date_of_week
    league.end_date_of_week(week,season)
  end

  def is_visible?
    status.closed? || status.revised? || status.evaluated?
  end

  def result
    is_visible? ? "#{home_goals} - #{away_goals}" : "-"
  end

  def player_in_club_home? player
    club_home.player_ids_on_date(date).include? player.id unless player.blank?
  end

  def player_in_club_away? player
    club_away.player_ids_on_date(date).include? player.id unless player.blank?
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

  def players_who_played(player_ids)
    lineups.of_players(player_ids).map(&:player) +
    substitutions.of_players_in(player_ids).map(&:player_in)
  end

  def players_who_played_of_club(club)
    player_ids = club.player_ids_on_date(date)
    players_who_played(player_ids)
  end

  def players_who_played_of_club_in_position(club, position)
    player_ids = club.player_ids_in_position_on_date(position, date)
    players_who_played(player_ids)
  end

  def update_winners_stats
    club = winner_club
    unless club.blank?
      players_who_played_of_club(club).each do |player|
        player.update_stats(id, WINNER_STAT)
      end
    end
  end

  def update_unbeaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.update_stats(id, UNBEATEN_GOALKEEPER_STAT)
    end
    players_who_played_of_club_in_position(club,'defender').each do |player|
      player.update_stats(id, UNBEATEN_DEFENDER_STAT)
    end
  end

  def update_beaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.update_stats(id, BEATEN_GOALKEEPER_STAT)
    end
  end

  def update_defenders_stats(club, goals)
    if goals == 0
      update_unbeaten_stats(club)
    elsif goals == 1
      update_beaten_stats(club)
    end
  end

  def update_players_stats
    update_winners_stats if home_goals != away_goals
    update_defenders_stats(club_home, away_goals) if away_goals < 2
    update_defenders_stats(club_away, home_goals) if home_goals < 2
  end

  def restore_winners_stats
    club = winner_club
    unless club.blank?
      players_who_played_of_club(club).each do |player|
        player.remove_stats(id, WINNER_STAT)
      end
    end
  end

  def restore_unbeaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.remove_stats(id, UNBEATEN_GOALKEEPER_STAT)
    end
    players_who_played_of_club_in_position(club,'defender').each do |player|
      player.remove_stats(id, UNBEATEN_DEFENDER_STAT)
    end
  end

  def restore_beaten_stats(club)
    players_who_played_of_club_in_position(club,'goalkeeper').each do |player|
      player.remove_stats(id, BEATEN_GOALKEEPER_STAT)
    end
  end

  def restore_defenders_stats(club, goals)
    if goals == 0
      restore_unbeaten_stats(club)
    elsif goals == 1
      restore_beaten_stats(club)
    end
  end

  def restore_players_stats
    restore_winners_stats if home_goals != away_goals
    restore_defenders_stats(club_home, away_goals) if away_goals < 2
    restore_defenders_stats(club_away, home_goals) if home_goals < 2
  end

  private

  def club_valid_lineups_count? club
    player_ids = club.player_ids_on_date(date)
    lineups.of_players(player_ids).count == Lineup.max_per_game
  end

  def valid_lineups_count?
    club_valid_lineups_count?(club_home) && club_valid_lineups_count?(club_away)
  end

  def validate_play_himself
    errors.add(:club_home, :cant_play_himself) if play_himself?
  end

  def validate_clubs_league
    errors.add(:club_home, :should_play_same_league) unless club_home_play_league?
    errors.add(:club_away, :should_play_same_league) unless club_away_play_league?
  end

  def initial_status
    errors.add(:status, :should_be_initial_status) unless initial_status?
  end

  def new_status
    errors.add(:status, :should_be_an_accepted_status) unless accepted_statuses(status_was).include? status
  end

  def number_of_lineups
    errors.add(:lineups, :should_have_right_number_of_lineups) unless valid_lineups_count?
  end

  def trigger_status_events
    self.send(STATUS_EVENTS[status_was][status]) if STATUS_EVENTS[status_was] && STATUS_EVENTS[status_was][status]
  end
end
