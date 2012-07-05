class Card < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event

  include Enumerize
  enumerize :kind, in: %w(yellow red), default: 'yellow'

  validates :kind,  presence: true, inclusion: { in: Card.kind.values }

  scope :red, where(kind: 'red')
  scope :in_game, ->(game) { where(game_id: game) }

  before_save :update_stats, if: 'player_id_changed?'
  before_destroy :restore_stats

  def kind_enum
    Card.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.player.name} (#{self.minute}') (#{I18n.t("enumerize.card.kind.#{self.kind}").first})"
  end

  def red_card_points
    case player.yellow_cards.in_game(game).count
      when 0 then -3
      when 1 then -2
      else -1
    end
  end

  def card_stats
    if self.kind.yellow?
      return { points: -1, yellow_cards: 1 }
    else
      return { points: red_card_points, red_cards: 1 }
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
