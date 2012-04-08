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

  def paginated_games(season = season, week = week)
    per_page = games.season(season).week(week).count
    games.season(season).order(:date).page(week).per(per_page)
  end
end
