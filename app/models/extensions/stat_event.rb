module Extensions
  module StatEvent
    extend ActiveSupport::Concern

    included do
    end

    private

    def player_was player_relation = 'player'
      current_id = send("#{player_relation}_id")
      current_id_was = send("#{player_relation}_id_was")
      Player.find(current_id_was) if current_id_was and current_id != current_id_was
    end

    def update_player_stats player, player_stat
      player.update_stats(game_id, player_stat) unless player.blank?
    end

    def restore_player_stats player, player_stat
      player.remove_stats(game_id, player_stat) unless player.blank?
    end
  end
end
