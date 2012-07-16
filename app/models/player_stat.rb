class PlayerStat < ActiveRecord::Base
  belongs_to :player
  belongs_to :game

  attr_accessible :points, :goals_scored, :assists, :goals_conceded, :yellow_cards, :red_cards, :lineups, :games_played, :minutes_played

  validates :player_id, presence: true, uniqueness: { scope: :game_id }
  validates :game_id, presence: true
  validates :points, presence: true, length: { minimum: 1, maximum: 2 },
                  numericality: { only_integer: true, greater_than_or_equal_to: -99, :less_than_or_equal_to => 99 }
  validates :goals_scored, :assists, :goals_conceded, :yellow_cards, :red_cards, presence: true, length: { minimum: 1, maximum: 2 },
                  numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 99 }
  validates :lineups, :games_played, presence: true, length: { is: 1 },
                  numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 1 }
  validates :minutes_played, presence: true, length: { minimum: 1, maximum: 3 },
                  numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }

  scope :week, ->(week) { joins(:game).where(games: { week: week }) }
  scope :season, ->(season) { joins(:game).where(games: { season: season }) }
  scope :in_league, ->(league_id) { joins(:game).where(games: { league_id: league_id }) }
  scope :in_game, ->(game_id) { where(game_id: game_id) }
end
