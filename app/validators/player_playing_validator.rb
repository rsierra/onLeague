class PlayerPlayingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :should_be_playing) unless player_is_playing?(record.game, value, record.minute)
  end

  private

  def player_is_playing?(game, player, minute)
    !game.blank? && !player.blank? \
    && ( play_from_beginin?(game, player, minute) \
    || play_since_substitution?(game, player, minute))
  end

  def play_from_beginin?(game, player, minute)
    game.lineups.exists?(player_id: player) \
    && game.substitutions.before(minute).of(player).empty? \
    && game.cards.red.before(minute).of(player).empty?
  end

  def play_since_substitution?(game, player, minute)
    !game.lineups.exists?(player_id: player) \
    && !game.substitutions.before(minute).for(player).empty? \
    && game.cards.red.before(minute).of(player).empty?
  end
end
