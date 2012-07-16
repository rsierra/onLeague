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
  before_destroy :restore_in_stats
  before_destroy :restore_out_stats

  def title
    "#{self.player_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end

  def stats_in
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - self.minute
  end

  def stats_in_was
    STATS_IN.merge minutes_played: Player::MAX_MINUTES - (minute_was.blank? ? self.minute : self.minute_was)
  end

  def update_in_stats
    player_in_was.remove_stats(game_id, stats_in_was) unless player_in_id_was.blank?
    player_in.update_stats(game_id, stats_in)
  end

  def restore_in_stats
    player_in.remove_stats(game_id, stats_in)
  end

  def stats_out
    { minutes_played: self.minute - Player::MAX_MINUTES }
  end

  def stats_out_was
    { minutes_played: (minute_was.blank? ? self.minute : self.minute_was) - Player::MAX_MINUTES }
  end

  def update_out_stats
    player_out_was.remove_stats(game_id, stats_out_was) unless player_out_id_was.blank?
    player_out.update_stats(game_id, stats_out)
  end

  def restore_out_stats
    player_out.remove_stats(game_id, stats_out)
  end

  def self_club_substitutions_count
    club = player_out.club_on_date(game.date)
    club.blank? ? 0 : game.substitutions.exclude_id(id || 0).of_players_out(club.player_ids_on_date(game.date)).count
  end

  private

  def player_in_was
    Player.find(player_in_id_was)
  end

  def player_out_was
    Player.find(player_out_id_was)
  end

  def max_per_club
    errors.add(:game, :cant_have_more_substitutions) if self_club_substitutions_count >= MAX_PER_GAME
  end
end
