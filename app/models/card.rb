class Card < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event

  include Enumerize
  enumerize :kind, in: %w(yellow red), default: 'yellow'

  validates :kind,  presence: true, inclusion: { in: Card.kind.values }

  def kind_enum
    Card.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.player.name} (#{self.minute}') (#{I18n.t("enumerize.card.kind.#{self.kind}").first})"
  end
end
