class TeamFile < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  attr_accessible :date_in, :position, :value

  include Extensions::PlayerFile

  validates :team_id, presence: true

end
