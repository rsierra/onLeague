class CountryTranslation < ActiveRecord::Base
  belongs_to :country

  validates :country,  :presence => true
  validates :locale,  :presence => true, :uniqueness => { :scope => :country_id, :message => :only_one_locale }
  validates :name,  :presence => true, :length => { :maximum => 64 }

  after_initialize :default_values

  def locale_enum
    I18n.available_locales
  end

  private

  def default_values
    self.locale ||= I18n.locale
    self.name ||= Country.human_attribute_name(:name, :locale => self.locale)
  end
end