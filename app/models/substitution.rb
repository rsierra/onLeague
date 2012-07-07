class Substitution < ActiveRecord::Base
  STATS_IN = { points: 1, games_played: 1 }.freeze

  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out, second_player_relation: :player_in

  validates :player_in, presence: true
  validates :player_in, player_not_play_yet: true, if: 'player_in_id_changed? '

  before_save :update_in_stats, if: 'player_in_id_changed? || minute_changed?'
  before_save :update_out_stats, if: 'player_out_id_changed?  || minute_changed?'
  before_destroy :restore_in_stats
  before_destroy :restore_out_stats

  def title
    "#{self.player_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end

  def update_in_stats
    stats_in = STATS_IN.merge minutes_played: Player::MAX_MINUTES - self.minute
    stats_in_was = STATS_IN.merge minutes_played: Player::MAX_MINUTES - (minute_was.blank? ? self.minute : self.minute_was)

    Player.find(player_in_id_was).remove_stats(game.id, stats_in_was) unless player_in_id_was.blank?
    player_in.update_stats(game.id, stats_in)
  end

  def restore_in_stats
    player_in.remove_stats(game.id, stats_in)
  end

  def update_out_stats
    stats_out = { minutes_played: self.minute - Player::MAX_MINUTES }
    stats_out_was = { minutes_played: (minute_was.blank? ? self.minute : self.minute_was) - Player::MAX_MINUTES }

    Player.find(player_out_id_was).remove_stats(game.id, stats_out_was) unless player_out_id_was.blank?
    player_out.update_stats(game.id, stats_out)
  end

  def restore_out_stats
    player_out.remove_stats(game.id, stats_out)
  end

  private

  def player_in_was
    Player.find(player_in_id_was)
  end

  def player_out_was
    Player.find(player_out_id_was)
  end
end
