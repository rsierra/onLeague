class League < ActiveRecord::Base
  has_and_belongs_to_many :clubs
  has_many :games

  validates :name, :presence => true, :uniqueness => true
  validates :week, :presence => true,
                  :numericality => { :only_integer => true },
                  :length => { :minimum => 1, :maximum => 2 }
  validates :season, :presence => true,
                    :numericality => { :only_integer => true },
                    :length => { :is => 4 }
  validates :active, :inclusion => { :in => [true, false] }

  scope :active, where(:active => true)
  scope :except, ->(id) { where(['id != ?',id]) }

  def paginated_games(find_week = week, find_season = season)
    per_page = games.season(find_season).week(find_week).count
    games.season(find_season).order(:date).page(find_week).per(per_page)
  end

  def end_date_of_week(find_week = week, find_season = season)
    games.season(find_season).week(find_week).maximum(:date)
  end

  def season_list
    games.select(:season).order(:season).uniq.map(&:season)
  end

  def season_week_list(find_season = season)
    games.where(season: find_season).select(:week).order(:week).uniq.map(&:week)
  end

  def current_games
    games.season(season).week(week)
  end

  def week_closeable?
    current_games.not_closeables.empty?
  end

  def next_week
    next_week = nil
    weeks = season_week_list
    unless weeks.last == week
      week_index = weeks.index(week)
      next_week = weeks[week_index + 1] if week_index
    end
    next_week
  end

  def advance_week
    new_week = next_week
    update_attributes(week: new_week) if new_week
  end
end
