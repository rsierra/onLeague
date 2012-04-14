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
end
