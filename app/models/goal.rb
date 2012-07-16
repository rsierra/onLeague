class Goal < ActiveRecord::Base
  ASSIST_STAT = { points: 1, assists: 1 }.freeze
  CONCEDED_STAT = { points: -1, goals_conceded: 1 }.freeze

  belongs_to :goalkeeper, class_name: 'Player'
  validates :goalkeeper, player_in_game: true, unless: "goalkeeper.blank?"
  validates :goalkeeper, player_playing: true, if: "goalkeeper_id_changed? && !goalkeeper.blank?"

  include Extensions::GameEvent
  acts_as_game_event player_relation: :scorer, second_player_relation: :assistant

  include Enumerize
  enumerize :kind, in: %w(regular own penalty penalty_saved penalty_out), default: 'regular'

  validates :kind,  presence: true, inclusion: { in: Goal.kind.values }
  validate :goal_assistant_presence, unless: "kind == 'regular'"
  validates :assistant, player_playing: true, unless: 'assistant.blank? || !assistant_id_changed?'

  scope :club, ->(club) { joins(:scorer => :club_files).where(club_files: {club_id: club}) }

  before_validation :goalkeeper_association, if: 'minute_changed? && !minute.blank? && !kind.blank? && !scorer.blank?'
  before_save :update_scorer_stats, if: 'scorer_id_changed? || kind_changed?'
  before_save :update_assistant_stats, if: 'assistant_id_changed?'
  before_save :update_goalkeeper_stats, if: 'goalkeeper_id_changed? || kind_changed?'
  before_destroy :restore_stats

  def kind_enum
    Goal.kind.values
  end

  def title
    "#{self.player_file.club_name}, #{self.scorer.name} (#{self.minute}')"
  end

  def goal_assistant_presence
    errors.add(:assistant, :should_not_be) unless assistant_id.blank?
  end

  def scorer_stats_by_kind(kind)
    case kind
      when 'penalty_out' then { points: -3 }
      when 'penalty_saved' then { points: -2 }
      when 'penalty' then { points: 2, goals_scored: 1 }
      when 'own' then { points: -2 }
      when 'regular' then { points: scorer.position_on_date(game.date) == 'forward' ? 2 : 3, goals_scored: 1 }
      else {}
    end
  end

  def scorer_stats
    scorer_stats_by_kind(kind)
  end

  def scorer_stats_was
    last_kind = kind_was.blank? ? self.kind : self.kind_was
    scorer_stats_by_kind(last_kind)
  end

  def update_scorer_stats
    Player.find(scorer_id_was).remove_stats(game_id, scorer_stats_was) unless scorer_id_was.blank?
    scorer.update_stats(game_id, scorer_stats)
  end

  def assistant_stats
    ASSIST_STAT
  end

  def update_assistant_stats
    Player.find(assistant_id_was).remove_stats(game_id, assistant_stats) unless assistant_id_was.blank?
    assistant.update_stats(game_id, assistant_stats) unless assistant_id.blank?
  end

  def goalkeeper_stats_by_kind(kind)
    case kind
      when 'penalty_out' then { points: 1 }
      when 'penalty_saved' then { points: 3 }
      when 'penalty' then CONCEDED_STAT
      when 'own' then CONCEDED_STAT
      when 'regular' then CONCEDED_STAT
      else {}
    end
  end

  def goalkeeper_stats
    goalkeeper_stats_by_kind(kind)
  end

  def goalkeeper_stats_was
    last_kind = kind_was.blank? ? self.kind : self.kind_was
    goalkeeper_stats_by_kind(last_kind)
  end

   def update_goalkeeper_stats
    Player.find(goalkeeper_id_was).remove_stats(game_id, goalkeeper_stats_was) unless goalkeeper_id_was.blank?
    goalkeeper.update_stats(game_id, goalkeeper_stats) unless goalkeeper_id.blank?
  end

  def restore_stats
    scorer.remove_stats(game_id, scorer_stats)
    assistant.remove_stats(game_id, assistant_stats) unless assistant.blank?
    goalkeeper.remove_stats(game_id, goalkeeper_stats) unless goalkeeper.blank?
  end

  private

  def goalkeeper_association
    club = scorer.club_on_date(game.date)
    self.goalkeeper = kind.own? ? game.goalkeeper_in_club_id_on_minute(club.id, minute) : game.goalkeeper_against_club_id_on_minute(club.id, minute)
  end
end
