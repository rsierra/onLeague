class League < ActiveRecord::Base
  has_and_belongs_to_many :clubs

  validates :name, :presence => true, :uniqueness => true
  validates :week, :presence => true,
                  :numericality => { :only_integer => true },
                  :length => { :minimum => 1, :maximum => 2 }
  validates :season, :presence => true,
                    :numericality => { :only_integer => true },
                    :length => { :is => 4 }
  validates :active, :inclusion => { :in => [true, false] }

  scope :active, where(:active => true)
  scope :except, ->(id) { where(['id != ?',id]) }
end
