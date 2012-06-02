class Substitution < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out
  belongs_to :player_in, class_name: 'Player'

  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }

  def title
    "#{self.player_out_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end

  def player_out_file
    player_out.club_files.on(game.end_date_of_week).last
  end
end
