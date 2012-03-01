class User < ActiveRecord::Base

  has_many :oauth_providers, :dependent => :destroy

  validate :name, :presence => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  # Gravatar configuration
  include Gravtastic
  gravtastic  :email, :secure => true, :filetype => :gif, :size => 32

  scope :latest, ->(n=10) { order("created_at DESC").limit(n) }

  def avatar_url
    gravatar_url
  end

  def has_provider?(provider)
    oauth_providers.exists?(:provider => provider)
  end

  def apply_omniauth(omniauth)
    self.email = omniauth.info.email if email.blank?
    self.name = omniauth.info.name if name.blank?
    if self.new_record?
      oauth_providers.build(:provider => omniauth.provider, :uid => omniauth.uid, :uemail => omniauth.info.email, :uname => omniauth.info.name)
      skip_confirmation! # Sets confirmed_at to Time.now, activating the account
    else
      oauth_providers.create(:provider => omniauth.provider, :uid => omniauth.uid, :uemail => omniauth.info.email, :uname => omniauth.info.name)
    end
  end
end
