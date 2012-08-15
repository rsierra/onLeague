module Extensions
  module PlayerFile
    extend ActiveSupport::Concern
    POSITION_TYPES = %w(goalkeeper defender midfielder forward)

    included do
      belongs_to :player

      include Enumerize
      enumerize :position, in: POSITION_TYPES

      delegate :name, to: :player, prefix: true, allow_nil: true

      validates :player_id, presence: true
      validates :player_id, uniqueness: { scope: :date_out, message: :only_one_curent_file_player }, if: "date_out.blank?"
      validates :position, presence: true, inclusion: { in: POSITION_TYPES }
      validates :value, presence: true, numericality: true
      validates :date_in, presence: true

      scope :current, where(date_out: nil)
      scope :on, ->(date) { order(:date_in).where(['date_in <= ? AND (date_out >= ? OR date_out IS NULL)',date,date]) }
      scope :of, ->(player) { where(player_id: player) }
      scope :exclude_id, ->(id=0) { where('id != ?', id) }

      validate :validate_date_out_blank, if: "new_record?"
      validate :validate_out_after_in, unless: "date_out.blank?"
      validate :validate_in_after_last_out, unless: "player.blank?"
    end

    def current?
      date_out.blank?
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
