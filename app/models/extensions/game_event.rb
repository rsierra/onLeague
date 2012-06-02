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

        validates :game, presence: true
        validates self.player_relation, presence: true, player_in_game: true
      end
    end
  end
end