class TeamFile < ActiveRecord::Base
  MAX_FILES = 11

  belongs_to :team
  belongs_to :player
  attr_accessible :player_id, :club_id, :date_in, :date_out, :position, :value

  include Extensions::PlayerFile

  validates :team_id, presence: true

  validate :max_files_per_team, unless: 'team.blank?'
  validate :enough_money, unless: 'team.blank?'

  def enough_money?
    team.remaining_money >= value
  end

  private

  def max_files_per_team
    errors.add(:team, :cant_have_more) if team.files.count >= MAX_FILES
  end

  def enough_money
    errors.add(:team, :not_enough_money) unless enough_money?
  end
end
