class PlayerInGameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :should_play_in_any_club) unless player_play_in_game?(record.game, value)
  end

  private

  def player_play_in_game?(game, player)
    !game.blank? && (game.player_in_club_home?(player) || game.player_in_club_away?(player))
  end
end