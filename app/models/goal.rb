class Goal < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :scorer, second_player_relation: :assistant

  include Enumerize
  enumerize :kind, in: %w(regular own penalty penalty_saved penalty_out), default: 'regular'

  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :kind,  presence: true, inclusion: { in: Goal.kind.values }

  scope :club, ->(club) { joins(:scorer => :club_files).where(club_files: {club_id: club}) }

  def kind_enum
    Goal.kind.values
  end

  def title
    "#{self.scorer_file.club_name}, #{self.scorer.name} (#{self.minute}')"
  end
end
