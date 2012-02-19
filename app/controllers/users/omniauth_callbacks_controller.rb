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
    puts omniauth.to_yaml
    oauth_provider = OauthProvider.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if oauth_provider
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, oauth_provider.user)
    elsif current_user
      current_user.oauth_providers.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to root_path
    else
      user_params = {
        :email => omniauth['info']['email'],
        :alias => omniauth['info']['name'],
        :password => "aaaaaa",
        :password_confirmation => "aaaaaa"
      }
      user = User.new user_params
      user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
      user.oauth_providers.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
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