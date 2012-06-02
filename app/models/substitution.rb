class Substitution < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out
  belongs_to :player_in, class_name: 'Player'

  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :player_in, presence: true, player_in_game: true
  validate :validate_player_in_clubs, unless: "player_in.blank?"

  def title
    "#{self.player_out_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end

  def player_out_file
    player_out.club_files.on(game.end_date_of_week).last
  end

  def player_in_file
    player_in.club_files.on(game.end_date_of_week).last
  end

  def same_player?
    player_in == player_out
  end

  def same_club?
    player_out_file.club == player_in_file.club unless player_out_file.blank? || player_in_file.blank?
  end

  def validate_player_in_clubs
    errors.add(:player_in, :should_be_in_same_club) unless same_club?
    errors.add(:player_in, :should_be_diferent) if same_player?
  end
end
