class Card < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  include Enumerize
  enumerize :kind, in: %w(yellow red), default: 'yellow'

  validates :game, :player, presence: true
  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :kind,  presence: true, inclusion: { in: Card.kind.values }
  validate :validate_player

  def kind_enum
    Card.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.player.name} (#{self.minute}') (#{I18n.t("enumerize.card.kind.#{self.kind}").first})"
  end

  def player_play_in_game?
    !game.blank? && (game.player_in_club_home?(player) || game.player_in_club_away?(player))
  end

  def validate_player
    errors.add(:player, :should_play_in_any_club) unless player_play_in_game?
  end

  def player_file
    player.club_files.on(game.end_date_of_week).last
  end
end
