class Player < ActiveRecord::Base
  MAX_MINUTES = 90

  belongs_to :country

  has_many :club_files
  has_one :file, :class_name => 'ClubFile', :conditions => 'date_out is null'
  has_one :club, :through => :file
  has_many :lineups
  has_many :goals, foreign_key: :scorer_id
  has_many :assists, :class_name => 'Goal', foreign_key: :assistant_id
  has_many :cards
  has_many :yellow_cards, :class_name => 'Card', :conditions => { kind: 'yellow' }
  has_many :red_cards, :class_name => 'Card', :conditions => { kind: 'red' }
  has_many :direct_red_cards, :class_name => 'Card', :conditions => { kind: 'direct_red' }
  has_many :substitutions_out, :class_name => 'Substitution', foreign_key: :player_out_id
  has_many :substitutions_in, :class_name => 'Substitution', foreign_key: :player_in_id
  has_many :stats, :class_name => 'PlayerStat'

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 64 }
  validates :born, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  validates :eu, :inclusion => { :in => [true, false] }
  validates :country_id, :presence => true
  validates :slug,  :presence => true, :uniqueness => true

  scope :active, where(:active => true)

  def last_date_out
    club_files.maximum(:date_out)
  end

  def update_stats(game_id, new_stats)
    stat = self.stats.find_or_initialize_by_game_id(game_id)
    updated_stats = {}
    new_stats.each { |key, value|  updated_stats[key] = stat[key] + value }
    stat.update_attributes(updated_stats)
  end

  def remove_stats(game_id, new_stats)
    stat = self.stats.find_by_game_id(game_id)
    unless stat.blank?
      updated_stats = {}
      new_stats.each { |key, value|  updated_stats[key] = stat[key] - value }
      stat.update_attributes(updated_stats)
    end
  end

  def minutes_played_in_game(game_id)
    stat = self.stats.select(:minutes_played).in_game(game_id).first
    stat.blank? ? 0 : stat.minutes_played
  end

  def club_file_on_date(date=Date.today)
    club_files.on(date).first
  end

  def club_on_date(date=Date.today)
    club_file = club_file_on_date date
    club_file.blank? ? nil : club_file.club
  end

  def position_on_date(date=Date.today)
    club_file = club_file_on_date date
    club_file.blank? ? nil : club_file.version_at(date).position
  end

  def league_stats(stat,league)
    stats.in_league(league).sum(stat)
  end

  def season_stats(stat,league, season=league.season)
    stats.in_league(league).season(season).sum(stat)
  end

  def week_stats(stat,league, season=league.season, week=league.week)
    stats.in_league(league).season(season).week(week).sum(stat)
  end
end
