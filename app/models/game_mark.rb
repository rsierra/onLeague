class GameMark < ActiveRecord::Base
  include Extensions::EventUtils

  belongs_to :player
  validates :player_id, uniqueness: { scope: :game_id }
  validates :player, presence: true, player_in_game: true

  validates :mark,  presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }

  before_save :update_stats, if: 'player_id_changed? || mark_changed?'
  before_destroy :restore_stats

  def stats
    { points: mark }
  end

  def stats_was
    { points: mark_was }
  end

  def update_stats
    restore_player_stats player_was, stats_was
    update_player_stats player, stats
  end

  def restore_stats
    restore_player_stats player, stats
  end
end
