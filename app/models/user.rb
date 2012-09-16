class User < ActiveRecord::Base

  has_many :teams

  has_many :oauth_providers, :dependent => :destroy

  validates :name, :presence => true

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
    provider = oauth_providers.first
    provider_name = provider ? provider.provider : nil
    case provider_name
      when 'google' then GooglePlus::Person.get(provider.uid).image.url rescue gravatar_url
      when 'twitter' then Twitter.user(provider.uid.to_i).profile_image_url rescue gravatar_url
      when 'facebook' then Koala::Facebook::API.new.get_picture(provider.uid) rescue gravatar_url
      else gravatar_url
    end
  end

  def has_provider?(provider)
    oauth_providers.exists?(:provider => provider)
  end

  def apply_omniauth(omniauth)
    self.email = omniauth.info.email if email.blank?
    self.name = omniauth.info.name if name.blank?
    oauth_providers_params = { provider: omniauth.provider, uid: omniauth.uid, uemail: omniauth.info.email, uname: omniauth.info.name }
    if self.new_record?
      oauth_providers.build(oauth_providers_params)
      skip_confirmation! # Sets confirmed_at to Time.now, activating the account
    else
      oauth_providers.create(oauth_providers_params)
    end
  end

  def remaining_teams_in_league league
    Team::MAX_TEAMS - teams.of_league_season(league).count
  end
end
