module Extensions
  module GameEvent
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_game_event(options = {})
        class_attribute :player_relation
        self.player_relation = (options[:player_relation] || :player)

        belongs_to :game
        validates :game, presence: true

        belongs_to self.player_relation, class_name: 'Player'
        validates self.player_relation, presence: true, player_in_game: true

        validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }

        scope :of, ->(player) { where("#{self.player_relation}_id" => player) }
        scope :before, ->(minute) { where(['minute <= ?', minute]) }

        unless options[:second_player_relation].blank?
          class_attribute :second_player_relation
          self.second_player_relation = options[:second_player_relation]

          belongs_to self.second_player_relation, class_name: 'Player'
          validates self.second_player_relation, player_in_game: true, unless: "#{self.second_player_relation}.blank?"
          validate :validate_player_in_clubs, unless: "#{self.second_player_relation}.blank?"

          scope :for, ->(player) { where("#{self.second_player_relation}_id" => player) }

          include SecondPlayerMethods
        end
      end
    end

    def event_player
      send(self.player_relation)
    end

    def player_file
      event_player.club_files.on(game.end_date_of_week).last
    end
    end
  end

  module SecondPlayerMethods
    def event_second_player
      send(self.second_player_relation)
    end

    def second_player_file
      event_second_player.club_files.on(game.end_date_of_week).last
    end

    def same_player?
      event_second_player == event_player
    end

    def same_club?
      player_file.club == second_player_file.club unless player_file.blank? || second_player_file.blank?
    end

    def validate_player_in_clubs
      errors.add(self.second_player_relation, :should_be_in_same_club) unless same_club?
      errors.add(self.second_player_relation, :should_be_diferent) if same_player?
    end
  end
end