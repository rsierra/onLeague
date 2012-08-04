module Extensions
  module EventUtils
    extend ActiveSupport::Concern

    include Extensions::StatEvent

    included do
      class_attribute :max_per_game
      class_attribute :player_relation
      self.player_relation = :player

      belongs_to :game
      validates :game, presence: true

      scope :exclude_id, ->(id=0) { where('id != ?', id) }
      scope :in_game, ->(game) { where(game_id: game) }
      scope :of, ->(player) { where("#{self.player_relation}_id" => player) }
      scope :of_players, ->(player_ids=[]) { where("#{self.player_relation}_id IN (?)", player_ids) }

      validate :max_per_club, unless: 'max_per_game.blank? || game_id.blank? || event_player.blank?'
      validate :game_active, unless: 'game_id.blank?'
    end

    def title
      "#{self.player_file.club_name}, #{self.event_player.name}"
    end

    def event_player
      send(self.player_relation)
    end

    def player_file
      event_player.club_files.on(game.end_date_of_week).last
    end

    def count_another_in_game
      club = event_player.club_on_date(game.date)
      club.blank? ? 0 : self.class.in_game(game).exclude_id(id || 0).of_players(club.player_ids_on_date(game.date)).count
    end

    def home?
      game.player_in_club_home? event_player
    end

    def away?
      game.player_in_club_away? event_player
    end

    private

    def max_per_club
      errors.add(:game,:cant_have_more) if count_another_in_game >= max_per_game
    end

    def game_active
      errors.add(:game,:should_be_active) unless game.status.active?
    end
  end
end
