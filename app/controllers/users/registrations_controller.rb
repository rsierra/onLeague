class Users::RegistrationsController < Devise::RegistrationsController
  private
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
    end
  end
end