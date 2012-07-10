class Lineup < ActiveRecord::Base
  STATS = { points: 2, lineups: 1, games_played: 1, minutes_played: 90 }.freeze

  belongs_to :game
  belongs_to :player

  validates :game_id, presence: true
  validates :player_id, uniqueness: { scope: :game_id }
  validates :player, presence: true, player_in_game: true

  before_save :update_stats, if: 'player_id_changed?'
  before_destroy :restore_stats

  def title
    "#{self.player_file.club_name}, #{self.player.name}"
  end

  def player_file
    player.club_files.on(game.end_date_of_week).last
  end

  def update_stats
    Player.find(player_id_was).remove_stats(game.id, STATS) unless player_id_was.blank?
    player.update_stats(game.id, STATS)
  end

  def restore_stats
    player.remove_stats(game.id, STATS)
  end
end
