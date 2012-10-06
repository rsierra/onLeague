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
      validates :player_id, presence: true
      validates :position, presence: true, inclusion: { in: POSITION_TYPES }
      validates :value, presence: true, numericality: true
      validates :date_in, presence: true

      scope :current, where(date_out: nil)
      scope :closed, where("#{self.table_name}.date_out IS NOT NULL")
      scope :after, ->(date) { where("#{self.table_name}.date_out > ?", date) }
      scope :closed_after, ->(date) { closed.after date }

      scope :active, joins(:player).where(players: { active: true })
      scope :no_eu, joins(:player).where(players: { eu: false })
      scope :on, ->(date) { where(["#{self.table_name}.date_in <= ? AND (#{self.table_name}.date_out >= ? OR #{self.table_name}.date_out IS NULL)",date,date]) }
      scope :of, ->(player) { where(player_id: player) }
      scope :of_players, ->(player_ids=[]) { where("#{self.table_name}.player_id IN (?)", player_ids) }
      scope :of_clubs, ->(club_ids=[]) { where("#{self.table_name}.club_id IN (?)", club_ids) }
      scope :exclude_id, ->(id=0) { where("#{self.table_name}.id != ?", id) }
      scope :exclude_ids, ->(ids=[0]) { where("#{self.table_name}.id NOT IN (?)", ids) }

      self::SQL_ATTRIBUTES = self.attribute_names.map{ |attr| "#{self.table_name}.#{attr}"}.join(',')
      self::SQL_JOINS = "LEFT OUTER JOIN player_stats ON #{self.table_name}.player_id = player_stats.player_id " +
                  "LEFT OUTER JOIN games ON player_stats.game_id = games.id"
      scope :with_points, joins(self::SQL_JOINS)
            .select("#{self::SQL_ATTRIBUTES}, COALESCE(player_stats.points,0) as points")

      scope :with_sum_points, joins(self::SQL_JOINS)
            .select("#{self::SQL_ATTRIBUTES}, COALESCE(sum(player_stats.points),0) as points")
            .group(self::SQL_ATTRIBUTES)

      scope :with_points_on_season, ->(season) {
            with_sum_points
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

      scope :with_points_on_season_by_week, ->(season) {
            with_points
            .select("games.week as week")
            .where(["games.season = ? OR games.season IS NULL",season])
          }

      validate :validate_date_out_blank, if: "new_record?"
      validate :validate_out_after_in, unless: "date_out.blank?"
      validate :validate_in_after_last_out, unless: "player.blank?"
    end

    module ClassMethods
      def season_avg_points_by_week_hash league, season = league.season
        avg_points = {}
        PlayerStat.league_season_avg_points_by_week(league, season).each { |file| avg_points[file.week.to_i] = file.points.to_i }
        avg_points
      end
    end

    def current?
      date_out.blank?
    end

    def value_million
      value * 1000000
    end

    def season_points_by_week_hash league, season = league.season
      points = {}
      self.class.where(id: id).with_points_on_season_by_week(season).each { |file| points[file.week.to_i] = file.points.to_i }
      points
    end

    def season_week_points_array_for_chart league, season = league.season
      avg_points = self.class.season_avg_points_by_week_hash league, season
      points = season_points_by_week_hash league, season
      avg_points.sort.map { |week_points| { week: week_points.first, points: points[week_points.first].to_i, average_points: week_points.last } }
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
