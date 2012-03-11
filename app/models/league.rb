class League < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :week, :presence => true,
                  :numericality => { :only_integer => true },
                  :length => { :minimum => 1, :maximum => 2 }
  validates :season, :presence => true,
                    :numericality => { :only_integer => true },
                    :length => { :is => 4 }
end
