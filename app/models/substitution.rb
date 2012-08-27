class Substitution < ActiveRecord::Base
  STATS_IN = { points: 1, games_played: 1 }.freeze


  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out, second_player_relation: :player_in
  self.max_per_game = 3

  validates :player_in, presence: true
  validates :player_in, player_not_play_yet: true, if: 'player_in_id_changed? '

  scope :of_players_in, ->(player_in_ids=[]) { where('player_in_id IN (?)', player_in_ids) }

  before_save :update_in_stats, if: 'player_in_id_changed? || minute_changed?'
  before_save :update_out_stats, if: 'player_out_id_changed?  || minute_changed?'
  before_destroy :restore_stats

  def player_in_was
    player_was :player_in
  end

  def stats_in
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - self.minute
  end

  def stats_in_was
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - (minute_was.blank? ? self.minute : self.minute_was)
  end

  def update_in_stats
    restore_player_stats player_in_was, stats_in_was if changed?
    update_player_stats player_in, stats_in
  end

  def player_out_was
    player_was :player_out
  end

  def stats_out
    { minutes_played: self.minute - Player::MAX_MINUTES }
  end

  def stats_out_was
    { minutes_played: (minute_was.blank? ? self.minute : self.minute_was) - Player::MAX_MINUTES }
  end

  def update_out_stats
    restore_player_stats player_out_was, stats_out_was if changed?
    update_player_stats player_out, stats_out
  end

  def restore_stats
    restore_player_stats player_out, stats_out
    restore_player_stats player_in, stats_in
  end
end
