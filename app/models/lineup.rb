class Lineup < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validates :game, presence: true
  validates :player, presence: true, player_in_game: true
end
