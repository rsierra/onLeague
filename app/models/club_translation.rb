class ClubTranslation < ActiveRecord::Base
  belongs_to :club

  validates :club,  :presence => true
  validates :locale,  :presence => true, :uniqueness => { :scope => :club_id, :message => :only_one_locale }
  validates :description,  :presence => true

  after_initialize :default_values

  def locale_enum
    I18n.available_locales
  end

  private

  def default_values
    self.locale ||= I18n.locale
    self.description ||= ClubTranslation.human_attribute_name(:description, :locale => self.locale)
  end
end