class PlayerNotPlayYetValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :should_not_play_yet) unless player_not_play_yet?(record.game, value, record.minute)
  end

  private

  def player_not_play_yet?(game, player, minute)
    !game.blank? && !player.blank? \
    && (!game.lineups.exists?(player_id: player) \
    && game.substitutions.before(minute).for(player).empty? )
  end
end
