class Player < ActiveRecord::Base
  belongs_to :country

  has_many :club_files
  has_one :file, :class_name => 'ClubFile', :conditions => 'date_out is null'
  has_one :club, :through => :file
  has_many :goals, foreign_key: :scorer_id
  has_many :assists, :class_name => 'Goal', foreign_key: :assistant_id

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, :presence => true, :length => { :maximum => 64 }
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