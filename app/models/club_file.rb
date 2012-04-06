class ClubFile < ActiveRecord::Base
  belongs_to :club
  belongs_to :player

  include Enumerize
  enumerize :position, in: %w(goalkeeper defender midfielder forward)

  has_paper_trail only: [:number, :value, :position], on: [:update, :destroy]

  delegate :name, to: :player, prefix: true, allow_nil: true

  validates :club_id, presence: true
  validates :player_id, presence: true
  validates :player_id, uniqueness: { scope: :date_out, message: :only_one_curent_file_player }, if: "date_out.blank?"
  validates :number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 100 }
  validates :position, presence: true, inclusion: { in: ClubFile.position.values }
  validates :value, presence: true, numericality: true
  validates :date_in, presence: true

  validate :validate_date_out_blank, if: "new_record?"
  validate :validate_out_after_in, unless: "date_out.blank?"
  validate :validate_in_after_last_out
  validate :validate_versioning_only_in_current, on: :update

  scope :active, joins(:player).where(players: { active: true })
  scope :current, where(date_out: nil)

  def validate_date_out_blank
    errors.add(:date_out, :should_be_blank_in_creation) unless date_out.blank?
  end

  def validate_out_after_in
    errors.add(:date_out, :should_be_after_in) if date_out <= date_in
  end

  def validate_in_after_last_out
    last_date_out = player.last_date_out unless player.blank?
    errors.add(:date_in, :should_be_after_last_out) if !last_date_out.blank? && date_in <= player.last_date_out
  end

  def validate_versioning_only_in_current
    errors.add(:date_out, :prevents_versioning, fields: i18n_versioned_fields.to_sentence) if !current? && will_create_version?
  end

  def position_enum
    ClubFile.position.values
  end

  def current?
    date_out.blank?
  end

  def i18n_versioned_fields
    # only is the array of values to versioned
    only.map { |field| ClubFile.human_attribute_name(field).downcase }
  end

  private

  def will_create_version?
    # only is the array of values to versioned
    only.inject(false) { |result, value| result || send("#{value}_changed?") }
  end
end
