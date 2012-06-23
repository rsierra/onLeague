class Substitution < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out, second_player_relation: :player_in

  validates :player_in, presence: true

  def title
    "#{self.player_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end
end
