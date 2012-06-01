module Extensions
  module GameEvent
    extend ActiveSupport::Concern

    included do
      class_attribute :player_relation
      self.player_relation = :player
    end

    module ClassMethods
      def acts_as_game_event(options = {})
        self.player_relation = options[:player_relation] unless options[:player_relation].blank?

        belongs_to :game
        belongs_to self.player_relation, class_name: 'Player'

        validates :game, self.player_relation, presence: true
        validate :validate_player
      end
    end

    def validate_player
      errors.add(player_relation, :should_play_in_any_club) unless player_play_in_game?
    end

    private

    def player_play_in_game?
      !game.blank? && (game.player_in_club_home?(send(player_relation)) || game.player_in_club_away?(send(player_relation)))
    end
  end
end