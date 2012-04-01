class ClubFile < ActiveRecord::Base
  POSITIONS = %w(goalkeeper defender midfielder forward)

  belongs_to :club
  belongs_to :player

  include Enumerize
  enumerize :position, :in => POSITIONS

  delegate :name, :to => :player, :prefix => true, :allow_nil => true

  validates :club_id, :presence => true
  validates :player_id, :presence => true,
    :uniqueness => { :scope => [:club_id, :season_in, :week_in], :message => :only_one_player }
  validates :number, :presence => true, :numericality => { :only_integer => true }
  validates :position, :presence => true, :inclusion => { :in => POSITIONS }
  validates :value, :presence => true, :numericality => true
  validates :week_in, :presence => true, :numericality => { :only_integer => true }
  validates :season_in, :presence => true, :numericality => { :only_integer => true }

  def position_enum
    ClubFile.position.values
  end
end
