class Substitution < ActiveRecord::Base
  MAX_PER_GAME =3
  STATS_IN = { points: 1, games_played: 1 }.freeze

  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out, second_player_relation: :player_in

  validates :player_in, presence: true
  validates :player_in, player_not_play_yet: true, if: 'player_in_id_changed? '
  validate :max_per_club, unless: 'game_id.blank? || player_out.blank?'

  scope :of_players_out, ->(player_out_ids=[]) { where('player_out_id IN (?)', player_out_ids) }
  scope :of_players_in, ->(player_in_ids=[]) { where('player_in_id IN (?)', player_in_ids) }
  scope :exclude_id, ->(id=0) { where('id != ?', id) }
  scope :in_game, ->(game) { where(game_id: game) }

  before_save :update_in_stats, if: 'player_in_id_changed? || minute_changed?'
  before_save :update_out_stats, if: 'player_out_id_changed?  || minute_changed?'
  before_destroy :restore_stats

  def title
    "#{self.player_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end

  def player_in_was
    player_was player_in_id_was
  end

  def stats_in
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - self.minute
  end

  def stats_in_was
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - (minute_was.blank? ? self.minute : self.minute_was)
  end

  def update_in_stats
    restore_player_stats player_in_was, stats_in_was
    update_player_stats player_in, stats_in
  end

  def player_out_was
    player_was player_out_id_was
  end

  def stats_out
    { minutes_played: self.minute - Player::MAX_MINUTES }
  end

  def stats_out_was
    { minutes_played: (minute_was.blank? ? self.minute : self.minute_was) - Player::MAX_MINUTES }
  end

  def update_out_stats
    restore_player_stats player_out_was, stats_out_was
    update_player_stats player_out, stats_out
  end

  def restore_stats
    restore_player_stats player_out, stats_out
    restore_player_stats player_in, stats_in
  end

  def self_club_substitutions_count
    club = player_out.club_on_date(game.date)
    club.blank? ? 0 : game.substitutions.exclude_id(id || 0).of_players_out(club.player_ids_on_date(game.date)).count
  end

  private

  def max_per_club
    errors.add(:game, :cant_have_more_substitutions) if self_club_substitutions_count >= MAX_PER_GAME
  end

  def player_was id_was = player_id_was
    Player.find(id_was) if id_was
  end

  def update_player_stats player, player_stat
    player.update_stats(game_id, player_stat) unless player.blank?
  end

  def restore_player_stats player, player_stat
    player.remove_stats(game_id, player_stat) unless player.blank?
  end
end
