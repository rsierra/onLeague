class Substitution < ActiveRecord::Base
  include Extensions::GameEvent
  acts_as_game_event player_relation: :player_out, second_player_relation: :player_in

  validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
  validates :player_in, presence: true

  def title
    "#{self.player_out_file.club_name}, #{self.player_out.name} (#{self.minute}')"
  end
end
