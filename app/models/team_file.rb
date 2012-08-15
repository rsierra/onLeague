class TeamFile < ActiveRecord::Base
  MAX_FILES = 11

  belongs_to :team
  belongs_to :player
  attr_accessible :date_in, :date_out, :position, :value

  include Extensions::PlayerFile

  validates :team_id, presence: true

  validate :max_files_per_team, unless: 'team.blank?'

  private

  def max_files_per_team
    errors.add(:team, :cant_have_more) if team.files.count >= MAX_FILES
  end
end
