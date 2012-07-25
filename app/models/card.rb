class Card < ActiveRecord::Base
  STATS_YELLOW = { points: -1, yellow_cards: 1 }
  STATS_RED = { points: -1, yellow_cards: 1, red_cards: 1 }
  STATS_DIRECT_RED = { points: -3, red_cards: 1 }

  include Extensions::GameEvent
  acts_as_game_event

  include Enumerize
  enumerize :kind, in: %w(yellow red direct_red), default: 'yellow'

  validates :kind,  presence: true, inclusion: { in: Card.kind.values },
                uniqueness: { scope: [:player_id, :game_id], message: :should_only_one_kind }

  validate :not_any_red_before, if: '!kind.nil? && kind.yellow?'
  validate :yellow_before, :not_direct_red_before, if: '!kind.nil? && kind.red?'
  validate :not_red_before, if: '!kind.nil? && kind.direct_red?'

  scope :red, where("kind = 'red' OR kind = 'direct_red'")
  scope :in_game, ->(game) { where(game_id: game) }
  scope :exclude_id, ->(id=0) { where('id != ?', id) }

  before_save :update_stats, if: 'player_id_changed? || minute_changed? || kind_changed?'
  before_destroy :restore_stats

  def kind_enum
    Card.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.player.name} (#{self.minute}') (#{I18n.t("enumerize.card.kind.#{self.kind}").first})"
  end

  def card_stats
    if self.kind.yellow?
      return STATS_YELLOW
    elsif self.kind.red?
      return STATS_RED.merge minutes_played: self.minute - Player::MAX_MINUTES
    else
      return STATS_DIRECT_RED.merge minutes_played: self.minute - Player::MAX_MINUTES
    end
  end

  def card_stats_was
    last_kind = kind_was.blank? ? self.kind : self.kind_was
    last_minute = minute_was.blank? ? self.minute : self.minute_was
    if last_kind == Card.kind.values.first
      return STATS_YELLOW
    elsif last_kind == Card.kind.values.second
      return STATS_RED.merge minutes_played: last_minute - Player::MAX_MINUTES
    else
      return STATS_DIRECT_RED.merge minutes_played: last_minute - Player::MAX_MINUTES
    end
  end

  def update_stats
    restore_player_stats player_was, card_stats_was
    update_player_stats player, card_stats
  end

  def restore_stats
    restore_player_stats player, card_stats
  end

  def yellow_exists?
    player.yellow_cards.exclude_id(id || 0).in_game(game_id).before(minute).exists?
  end

  def red_exists?
    player.red_cards.exclude_id(id || 0).in_game(game_id).exists?
  end

  def direct_red_exists?
    player.direct_red_cards.exclude_id(id || 0).in_game(game_id).exists?
  end

  private

  def yellow_before
    errors.add(:kind, :should_exists_yellow_before) unless yellow_exists?
  end

  def not_red_before
    errors.add(:kind, :should_not_exist_any_red_before) if red_exists?
  end

  def not_direct_red_before
    errors.add(:kind, :should_not_exist_any_red_before) if direct_red_exists?
  end

  def not_any_red_before
    errors.add(:kind, :should_not_exist_any_red_before) if red_exists? || direct_red_exists?
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
