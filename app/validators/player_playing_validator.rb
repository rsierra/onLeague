class PlayerPlayingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :should_be_playing) unless player_is_playing?(record.game, value, record.minute)
  end

  private

  def player_is_playing?(game, player, minute)
    !game.blank? && !player.blank? \
    && ((game.lineups.exists?(player_id: player) \
    && game.substitutions.before(minute).of(player).empty? \
    && game.cards.red.before(minute).of(player).empty?) \
    || (!game.lineups.exists?(player_id: player) \
    && !game.substitutions.before(minute).for(player).empty? \
    && game.cards.red.before(minute).of(player).empty?))
  end
end