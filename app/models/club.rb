class Club < ActiveRecord::Base
  has_and_belongs_to_many :leagues

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name,  :presence => true, :uniqueness => true,
                    :length => { :maximum => 25 }
  validates :short_name,  :presence => true,
                          :length => { :maximum => 3 }
  validates :slug,  :presence => true, :uniqueness => true
end
