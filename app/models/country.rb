class Country < ActiveRecord::Base
  translates :name
  has_many :country_translations, :dependent => :destroy
  accepts_nested_attributes_for :country_translations
  validates_associated :country_translations

  has_attached_file :flag,  :styles => { :small => "16x11#" },
                            :default_url => "/assets/missings/:class/:attachment/:style/missing.png"

  validates_attachment_content_type :flag, :content_type => /image/, :message => :incorrect_format

  validates_attachment_size :flag, :less_than => 50.kilobytes

  validates :name, :presence => true, :length => { :maximum => 64 }

  after_create :default_values

  private

  def default_values
    I18n.available_locales.each do |locale|
      country_translations << CountryTranslation.create({ :locale => locale }) unless country_translations.exists?(:locale => locale)
    end
  end
end
