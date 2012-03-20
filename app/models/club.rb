class Club < ActiveRecord::Base
  has_and_belongs_to_many :leagues

  translates :description
  has_many :club_translations, :dependent => :destroy
  accepts_nested_attributes_for :club_translations
  validates_associated :club_translations

  extend FriendlyId
  friendly_id :name, use: :slugged

  #attr_accessible :logo
  has_attached_file :logo,  :styles => { :medium => "200x200>", :small => "100x100>", :thumb => "50x50#" },
                            :default_url => "/assets/missings/:class/:attachment/:style/missing.png"

  validates_attachment_content_type :logo, :content_type => /image/, :message => :incorrect_format

  validates_attachment_size :logo, :less_than => 500.kilobytes

  validates :name,  :presence => true, :uniqueness => true,
                    :length => { :maximum => 25 }
  validates :short_name,  :presence => true,
                          :length => { :maximum => 3 }
  validates :slug,  :presence => true, :uniqueness => true

  after_create :default_values

  private

  def default_values
    I18n.available_locales.each do |locale|
      club_translations << ClubTranslation.create({ :locale => locale }) unless club_translations.exists?(:locale => locale)
    end
  end
end
