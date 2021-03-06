module Extensions
  module GameEvent
    extend ActiveSupport::Concern

    include Extensions::EventUtils

    included do
      def title_with_minute
        "#{title_without_minute} (#{self.minute}')"
      end
      alias_method_chain :title, :minute
    end

    module ClassMethods
      def acts_as_game_event(options = {})
        self.player_relation = (options[:player_relation] || :player)

        belongs_to self.player_relation, class_name: 'Player'
        validates self.player_relation, presence: true, player_in_game: true
        validates self.player_relation, player_playing: true, if: "#{self.player_relation}_id_changed?"

        validates :minute,  presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0, :less_than_or_equal_to => 130 }
        scope :before, ->(minute) { order(:minute).where(['minute < ?', minute]) }

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
