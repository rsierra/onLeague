class Team < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  attr_accessible :money, :name, :season
end
