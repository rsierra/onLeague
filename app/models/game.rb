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

  after_find do
    @name = "#{club_home.name} - #{club_away.name}"
  end

  def custom_slug
    "#{club_home.name} #{club_away.name} #{season} #{week}"
  end

  def status_enum
    Game.status.values
  end

end
