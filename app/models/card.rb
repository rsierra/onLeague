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


  scope :red, where("kind = 'red' OR kind = 'direct_red'")
  scope :in_game, ->(game) { where(game_id: game) }

  before_save :update_stats, if: 'player_id_changed?'
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

  def update_stats
    Player.find(player_id_was).remove_stats(game.id, card_stats) unless player_id_was.blank?
    player.update_stats(game.id, card_stats)
  end

  def restore_stats
    player.remove_stats(game.id, card_stats)
  end
end
