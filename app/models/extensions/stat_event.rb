module Extensions
  module StatEvent
    extend ActiveSupport::Concern

    included do
    end

    private

    def player_was id_was = player_id_was
      Player.find(id_was) if id_was
    end

    def update_player_stats player, player_stat
      player.update_stats(game_id, player_stat) unless player.blank?
    end

    def restore_player_stats player, player_stat
      player.remove_stats(game_id, player_stat) unless player.blank?
    end
  end
end
