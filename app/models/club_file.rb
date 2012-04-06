class ClubFile < ActiveRecord::Base
  belongs_to :club
  belongs_to :player

  include Enumerize
  enumerize :position, in: %w(goalkeeper defender midfielder forward)

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

  def position_enum
    ClubFile.position.values
  end
end
