class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :alias, :email, :password, :password_confirmation, :remember_me

  # Gravatar configuration
  include Gravtastic
  gravtastic  :email, :secure => true, :filetype => :gif, :size => 32

  scope :latest, ->(n=10) { order("created_at DESC").limit(n) }

  def avatar_url
    gravatar_url
  end
end
