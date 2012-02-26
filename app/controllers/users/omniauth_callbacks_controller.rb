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

  def delete
    provider = params[:provider]
    if current_user && current_user.has_provider?(provider)
      current_user.oauth_providers.where(:provider => provider).first.destroy
      redirect_to edit_user_registration_path
    else
      flash[:alert] = t('devise.omniauth_callbacks.cant_delete', :provider => provider)
      redirect_to edit_user_registration_path
    end
  end

  private

  def create(omniauth)
    oauth_provider = OauthProvider.find_by_provider_and_uid(omniauth.provider, omniauth.uid)
    if oauth_provider
      flash[:notice] = t('devise.omniauth_callbacks.provider_success', :provider => omniauth.provider)
      sign_in_and_redirect(:user, oauth_provider.user)
    elsif current_user
      current_user.oauth_providers.create(:provider => omniauth.provider, :uid => omniauth.uid)
      flash[:notice] = t('devise.omniauth_callbacks.provider_linked', :provider => omniauth.provider)
      redirect_to edit_user_registration_path
    elsif User.exists? :email => omniauth.info.email
      user = User.find_by_email(omniauth.info.email)
      user.oauth_providers.create(:provider => omniauth.provider, :uid => omniauth.uid)
      flash[:notice] = t('devise.omniauth_callbacks.provider_linked', :provider => omniauth.provider)
      sign_in user
      redirect_to edit_user_registration_path
    else
      password = Devise.friendly_token[0,20]
      user_params = {
        :email => omniauth.info.email,
        :name => omniauth.info.name,
        :password => password,
        :password_confirmation => password
      }
      user = User.new user_params
      user.skip_confirmation! # Sets confirmed_at to Time.now, activating the account
      user.oauth_providers.build(:provider => omniauth.provider, :uid => omniauth.uid)
      if user.save
        flash[:notice] = t('devise.omniauth_callbacks.user_created', :provider => omniauth.provider)
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

end