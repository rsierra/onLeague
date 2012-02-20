class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    create request.env["omniauth.auth"]
  end

  def twitter
    create request.env["omniauth.auth"]
  end

  def google
    create request.env["omniauth.auth"]
  end

  private

  def create(omniauth)
    oauth_provider = OauthProvider.find_by_provider_and_uid(omniauth.provider, omniauth.uid)
    if oauth_provider
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, oauth_provider.user)
    elsif current_user
      current_user.oauth_providers.create(:provider => omniauth.provider, :uid => omniauth.uid)
      flash[:notice] = "Authentication successful."
      redirect_to root_path
    elsif User.exists? :email => omniauth.user_info.email
      user = User.find_by_email(omniauth.user_info.email)
      user.oauth_providers.create(:provider => omniauth.provider, :uid => omniauth.uid)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect(:user, user)
    else
      password = Devise.friendly_token[0,20]
      user_params = {
        :email => omniauth.user_info.email,
        :name => omniauth.user_info.name,
        :password => password,
        :password_confirmation => password
      }
      user = User.new user_params
      user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
      user.oauth_providers.build(:provider => omniauth.provider, :uid => omniauth.uid)
      if user.save
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

end