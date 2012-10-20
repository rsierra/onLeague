class TeamFile < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  attr_accessible :player_id, :club_id, :date_in, :date_out, :position, :value

  include Extensions::PlayerFile

  validates :team_id, presence: true
  validates :player_id, uniqueness: { scope: [:team_id, :date_out], message: :only_one_curent_file_player }, if: "date_out.blank?"

  validate  :max_files_per_team, :max_positions_per_team,
            :max_clubs_per_team, :max_no_eu_per_team,
            :enough_money, :minimum_files, unless: 'team.blank?', on: :create
  validate  :played, unless: 'player.blank? || team.blank?'

  before_destroy :played

  after_initialize :default_values

  private

  def default_values
    self.date_in ||= Date.today
  end

  def max_files_per_team
    errors.add(:team, :cant_have_more) unless team.remaining_files?
  end

  def enough_money
    errors.add(:team, :not_enough_money) unless team.enough_money? value
  end

  def max_positions_per_team
    errors.add(:team, :cant_have_more_positions, position: position.text.downcase.pluralize) unless team.remaining_position? position
  end

  def max_clubs_per_team
    errors.add(:team, :cant_have_more_clubs, club: club_name.capitalize) unless team.remaining_club? club
  end

  def max_no_eu_per_team
    errors.add(:team, :cant_have_more_no_eu) unless player.eu || team.remaining_no_eu?
  end

  def played
    errors.add(:player, :cant_be_played) if player.played_on_league? team.league
  end

  def minimum_files
    errors.add(:player, :cant_valid_minimums) unless team.valid_minimums? position
  end

  # Override player_file method, this validation only needs be checked on the player team.
  def player_last_date_out_before
    team.team_files.exclude_id(id || 0).of(player).maximum(:date_out) if team
  end
end
