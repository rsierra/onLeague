class Lineup < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validates :game, presence: true
  validates :player, presence: true, player_in_game: true

  def title
    "#{self.player_file.club_name}, #{self.player.name}"
  end

  def player_file
    player.club_files.on(game.end_date_of_week).last
  end
end
