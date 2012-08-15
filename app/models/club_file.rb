class ClubFile < ActiveRecord::Base
  include Extensions::PlayerFile

  has_paper_trail only: [:number, :value, :position], on: [:update, :destroy]

  validates :number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 100 }

  validate :validate_versioning_only_in_current, on: :update

  def validate_versioning_only_in_current
    errors.add(:date_out, :prevents_versioning, fields: i18n_versioned_fields.to_sentence) if !current? && will_create_version?
  end

  def title
    "#{self.player_name} (#{self.number})"
  end

  def position_enum
    ClubFile.position.values
  end

  def i18n_versioned_fields
    # only is the array of values to versioned
    only.map { |field| ClubFile.human_attribute_name(field).downcase }
  end

  def attributes_for_team_file
    wanted_keys = %w(player_id club_id position value)
    attributes.select { |key,_| wanted_keys.include? key }
  end

  private

  def will_create_version?
    # only is the array of values to versioned
    only.inject(false) { |result, value| result || send("#{value}_changed?") }
  end
end
