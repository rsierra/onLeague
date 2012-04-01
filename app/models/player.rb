class Player < ActiveRecord::Base
  belongs_to :country

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, :presence => true, :length => { :maximum => 64 }
  validates :born, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  validates :country_id, :presence => true
  validates :slug,  :presence => true, :uniqueness => true

  scope :active, where(:active => true)
end