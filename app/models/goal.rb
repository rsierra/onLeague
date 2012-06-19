class Goal < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :scorer, second_player_relation: :assistant

  include Enumerize
  enumerize :kind, in: %w(regular own penalty penalty_saved penalty_out), default: 'regular'

  validates :kind,  presence: true, inclusion: { in: Goal.kind.values }
  validate :own_goal_assistant, unless: "kind == 'regular'"
  validates :assistant, player_playing: true, unless: 'assistant.blank?'

  scope :club, ->(club) { joins(:scorer => :club_files).where(club_files: {club_id: club}) }

  def kind_enum
    Goal.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.scorer.name} (#{self.minute}')"
  end

  def own_goal_assistant
    errors.add(:assistant, :should_not_be) unless assistant_id.blank?
  end
end
