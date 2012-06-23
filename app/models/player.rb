class Player < ActiveRecord::Base
  belongs_to :country

  has_many :club_files
  has_one :file, :class_name => 'ClubFile', :conditions => 'date_out is null'
  has_one :club, :through => :file
  has_many :goals, foreign_key: :scorer_id
  has_many :assists, :class_name => 'Goal', foreign_key: :assistant_id
  has_many :cards
  has_many :yellow_cards, :class_name => 'Card', :conditions => 'red = 0'
  has_many :red_cards, :class_name => 'Card', :conditions => 'red = 1'
  has_many :substitutions_out, :class_name => 'Substitution', foreign_key: :player_out_id
  has_many :substitutions_in, :class_name => 'Substitution', foreign_key: :player_in_id

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 64 }
  validates :born, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  validates :eu, :inclusion => { :in => [true, false] }
  validates :country_id, :presence => true
  validates :slug,  :presence => true, :uniqueness => true

  scope :active, where(:active => true)

  def last_date_out
    club_files.maximum(:date_out)
  end
end