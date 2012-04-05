class Player < ActiveRecord::Base
  belongs_to :country

  has_many :club_files
  has_one :file, :class_name => 'ClubFile', :conditions => 'date_out is null'
  has_one :club, :through => :file

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, :presence => true, :length => { :maximum => 64 }
  validates :born, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  validates :country_id, :presence => true
  validates :slug,  :presence => true, :uniqueness => true

  scope :active, where(:active => true)
end