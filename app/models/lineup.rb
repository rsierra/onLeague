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
    Player.find(player_id_was).remove_stats(game.id, STATS) unless player_id_was.blank?
    player.update_stats(game.id, STATS)
  end

  def restore_stats
    player.remove_stats(game.id, STATS)
  end

  def self_club_lineups_count
    club = player.club_files.on(game.date).first.club
    game.lineups.exclude_id(id || 0).of_players(club.club_files.on(game.date).select(:player_id).map(&:player_id)).count
  end

  private

  def max_per_club
    errors.add(:game,:cant_have_more_lineups) if self_club_lineups_count >= MAX_PER_GAME
  end
end
