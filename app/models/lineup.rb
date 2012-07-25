class Lineup < ActiveRecord::Base
  MAX_PER_GAME = 11
  STATS = { points: 2, lineups: 1, games_played: 1, minutes_played: 90 }.freeze

  belongs_to :game
  belongs_to :player

  validates :game_id, presence: true
  validates :player_id, uniqueness: { scope: :game_id }
  validates :player, presence: true, player_in_game: true
  validate :max_per_club, unless: 'game_id.blank? || player_id.blank?'

  scope :of_players, ->(player_ids=[]) { where('player_id IN (?)', player_ids) }
  scope :exclude_id, ->(id=0) { where('id != ?', id) }

  before_save :update_stats, if: 'player_id_changed?'
  before_destroy :restore_stats

  def title
    "#{self.player_file.club_name}, #{self.player.name}"
  end

  def player_file
    player.club_files.on(game.end_date_of_week).last
  end

  def update_stats
    restore_player_stats player_was, STATS
    update_player_stats player, STATS
  end

  def restore_stats
    restore_player_stats player, STATS
  end

  def self_club_lineups_count
    club = player.club_on_date(game.date)
    club.blank? ? 0 : game.lineups.exclude_id(id || 0).of_players(club.player_ids_on_date(game.date)).count
  end

  private

  def max_per_club
    errors.add(:game,:cant_have_more_lineups) if self_club_lineups_count >= MAX_PER_GAME
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
