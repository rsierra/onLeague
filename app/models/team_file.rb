class TeamFile < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  attr_accessible :player_id, :club_id, :date_in, :date_out, :position, :value

  include Extensions::PlayerFile

  validates :team_id, presence: true

  validate :max_files_per_team, :max_positions_per_team, unless: 'team.blank?'
  validate :enough_money, unless: 'team.blank?'

  private

  def max_files_per_team
    errors.add(:team, :cant_have_more) unless team.remaining_files?
  end

  def enough_money
    errors.add(:team, :not_enough_money) unless team.enough_money? value
  end

  def max_positions_per_team
    errors.add(:team, :cant_have_more) unless team.remaining_position? position
  end
end
