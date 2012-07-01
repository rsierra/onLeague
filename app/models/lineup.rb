class Lineup < ActiveRecord::Base
  STATS = { points: 2, lineups: 1, games_played: 1, minutes_played: 90 }

  belongs_to :game
  belongs_to :player

  validates :game, presence: true
  validates :player, presence: true, player_in_game: true

  before_save :update_points, if: 'player_id_changed?'
  before_destroy :restore_points

  def title
    "#{self.player_file.club_name}, #{self.player.name}"
  end

  def player_file
    player.club_files.on(game.end_date_of_week).last
  end

  def update_points
    Player.find(player_id_was).remove_stats(game.id, STATS) unless player_id_was.blank?
    player.update_stats(game.id, STATS)
  end

  def restore_points
    player.remove_stats(game.id, STATS)
  end
end
