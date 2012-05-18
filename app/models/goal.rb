class Goal < ActiveRecord::Base
  belongs_to :game
  belongs_to :scorer, class_name: 'Player'
  belongs_to :assistant, class_name: 'Player'

  include Enumerize
  enumerize :kind, in: %w(regular own penalty penalty_saved penalty_out), default: 'regular'

  validates :game, :scorer, presence: true
  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :kind,  presence: true, inclusion: { in: Goal.kind.values }

  validate :validate_scorer
  validate :validate_assistant_clubs, unless: "assistant.blank?"

  scope :club, ->(club) { joins(:scorer => :club_files).where(club_files: {club_id: club}) }

  def kind_enum
    Goal.kind.values
  end

  def title
    "#{self.scorer_file.club_name}, #{self.scorer.name} (#{self.minute}')"
  end

  def scorer_play_in_game?
    !game.blank? && (game.player_in_club_home?(scorer) || game.player_in_club_away?(scorer))
  end

  def assistant_play_in_game?
    !game.blank? && (game.player_in_club_home?(assistant) || game.player_in_club_away?(assistant))
  end

  def same_player?
    scorer == assistant
  end

  def same_club?
    scorer_file.club == assistant_file.club unless scorer_file.blank? || assistant_file.blank?
  end

  def validate_scorer
    errors.add(:scorer, :should_play_in_any_club) unless scorer_play_in_game?
  end

  def validate_assistant_clubs
    errors.add(:assistant, :should_play_in_any_club) unless assistant_play_in_game?
    errors.add(:assistant, :should_be_in_same_club) unless same_club?
    errors.add(:assistant, :should_be_diferent) if same_player?
  end

  def scorer_file
    scorer.club_files.on(game.end_date_of_week).last
  end

  def assistant_file
    assistant.club_files.on(game.end_date_of_week).last
  end
end
