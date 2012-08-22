module Extensions
  module PlayerFile
    extend ActiveSupport::Concern
    POSITION_TYPES = %w(goalkeeper defender midfielder forward)

    included do
      belongs_to :club
      belongs_to :player

      include Enumerize
      enumerize :position, in: POSITION_TYPES

      delegate :name, to: :club, prefix: true, allow_nil: true
      delegate :name, to: :player, prefix: true, allow_nil: true

      validates :club_id, presence: true
      validates :player_id, presence: true,
          uniqueness: { scope: :date_out, message: :only_one_curent_file_player }, if: "date_out.blank?"
      validates :position, presence: true, inclusion: { in: POSITION_TYPES }
      validates :value, presence: true, numericality: true
      validates :date_in, presence: true

      scope :current, where(date_out: nil)
      scope :active, joins(:player).where(players: { active: true })
      scope :no_eu, joins(:player).where(players: { eu: false })
      scope :on, ->(date) { where(['date_in <= ? AND (date_out >= ? OR date_out IS NULL)',date,date]) }
      scope :of, ->(player) { where(player_id: player) }
      scope :of_players, ->(player_ids=[]) { where('player_id IN (?)', player_ids) }
      scope :of_clubs, ->(club_ids=[]) { where('club_id IN (?)', club_ids) }
      scope :exclude_id, ->(id=0) { where('id != ?', id) }

      self::SQL_ATTRIBUTES = self.attribute_names.map{ |attr| "#{self.table_name}.#{attr}"}.join(',')
      self::SQL_JOINS = "LEFT OUTER JOIN player_stats ON #{self.table_name}.player_id = player_stats.player_id " +
                  "LEFT OUTER JOIN games ON player_stats.game_id = games.id"
      scope :with_points, joins(self::SQL_JOINS)
            .select("#{self::SQL_ATTRIBUTES}, COALESCE(sum(player_stats.points),0) as points")
            .group(self::SQL_ATTRIBUTES)

      scope :with_points_on_season, ->(season) {
            with_points
            .where(["games.season = ? OR games.season IS NULL",season])
          }
      scope :with_points_on_season_week, ->(season, week) {
            with_points_on_season(season)
            .where(["games.week = ? OR games.week IS NULL",week])
          }
      scope :order_by_points_on_season, ->(season) {
            with_points_on_season(season)
            .order("COALESCE(sum(player_stats.points),0) DESC")
          }
      scope :order_by_points_on_season_week, ->(season,week) {
            order_by_points_on_season(season)
            .where(["games.week = ? OR games.week IS NULL",week])
          }

      validate :validate_date_out_blank, if: "new_record?"
      validate :validate_out_after_in, unless: "date_out.blank?"
      validate :validate_in_after_last_out, unless: "player.blank?"
    end

    def current?
      date_out.blank?
    end

    def value_million
      value * 1000000
    end

    private

    def player_last_date_out_before
      self.class.exclude_id(id || 0).of(player).maximum(:date_out)
    end

    def validate_date_out_blank
      errors.add(:date_out, :should_be_blank_in_creation) unless date_out.blank?
    end

    def validate_out_after_in
      errors.add(:date_out, :should_be_after_in) if date_out <= date_in
    end

    def validate_in_after_last_out
      errors.add(:date_in, :should_be_after_last_out) if !player_last_date_out_before.blank? && date_in <= player_last_date_out_before
    end
  end
end
