module Extensions
  module StatEvent
    extend ActiveSupport::Concern

    included do
    end

    private

    def player_was player_relation = 'player'
      dirty_id = send("#{player_relation}_id_was")
      Player.find(dirty_id) if dirty_id
    end

    def update_player_stats player, player_stat
      player.update_stats(game_id, player_stat) unless player.blank?
    end

    def restore_player_stats player, player_stat
      player.remove_stats(game_id, player_stat) unless player.blank?
    end
  end
end
