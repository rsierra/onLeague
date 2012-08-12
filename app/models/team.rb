class Team < ActiveRecord::Base
  MAX_TEAMS = 2
  INITIAL_MONEY = 200

  belongs_to :user
  belongs_to :league
  attr_accessible :name, :active, :activation_week

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

  before_validation :initial_values, unless: 'league.blank?'

  def initial_values
    self.money ||= INITIAL_MONEY
    self.season ||= self.league.season
  end

  def activate
    update_attributes(active: true, activation_week: league.week)
  end

  private

  def max_per_user
    errors.add(:user,:cant_have_more) if user.teams.of_league_season(league).count >= MAX_TEAMS
  end
end
