class Lineup < ActiveRecord::Base
  STATS = { points: 2, lineups: 1, games_played: 1, minutes_played: 90 }.freeze

  include Extensions::EventUtils
  self.max_per_game = 11

  belongs_to :player
  validates :player_id, uniqueness: { scope: :game_id }
  validates :player, presence: true, player_in_game: true

  before_save :update_stats, if: 'player_id_changed?'
  before_destroy :restore_stats

  def update_stats
    restore_player_stats player_was, STATS
    update_player_stats player, STATS
  end

  def restore_stats
    restore_player_stats player, STATS
  end
end
