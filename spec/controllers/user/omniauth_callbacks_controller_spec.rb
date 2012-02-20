require 'spec_helper'

OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:twitter, {
  :user_info => {:name => 'Twitter Name', :nickname => 'twitter_nick'},
  :uid => 'twitter_uid'
})

OmniAuth.config.add_mock(:facebook, {
  :user_info => { :email => 'facebook@mail.com', :name => 'Facebook Name', :nickname => 'facebook_nick'},
  :uid => 'facebook_uid'
})

OmniAuth.config.add_mock(:google, {
  :user_info => { :email => 'google@mail.com', :name => 'Google Name', :nickname => 'google_nick'},
  :uid => 'google_uid'
})

describe Users::OmniauthCallbacksController, "handle omniauth authentication callback" do

############
# FACEBOOK #
############

  describe "with facebook connect" do
    context "when user not exists" do
      before(:each) do
        mock_omniauth :facebook
        get :facebook
        @user = User.where(:email => "facebook@mail.com").first
      end

      after(:each) do
        @user = User.destroy_all
      end

      it { @user.should_not be_nil }

      it "should create authentication with facebook id" do
        oauth_provider = @user.oauth_providers.where(:provider => "facebook", :uid => "facebook_uid").first
        oauth_provider.should_not be_nil
      end

      it { should be_user_signed_in }

      it { response.should redirect_to root_path }
    end

    describe "and user exists" do

      describe "logged in" do
        context "when provider not exists" do
          before(:each) do
            mock_omniauth :facebook
            @user = FactoryGirl.create(:user)
            sign_in @user
            get :facebook
          end

          after(:each) do
            User.destroy_all
          end

          it "should create authentication with facebook id" do
            oauth_provider = @user.oauth_providers.where(:provider => "facebook", :uid => "facebook_uid").first
            oauth_provider.should_not be_nil
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }
        end
      end

      describe "not logged in" do
        context "when provider not exists but user email matches" do
          before(:each) do
            mock_omniauth :facebook
            @user = FactoryGirl.create(:user, :email => 'facebook@mail.com')
            get :facebook
          end

          after(:each) do
            User.destroy_all
          end

          it "should create authentication with facebook id" do
            oauth_provider = @user.oauth_providers.where(:provider => "facebook", :uid => "facebook_uid").first
            oauth_provider.should_not be_nil
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }
        end

        context "when provider exists" do
          before(:each) do
            mock_omniauth :facebook
            @user = FactoryGirl.create(:user_with_facebook)
            get :facebook
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }

          after(:each) do
            User.destroy_all
          end
        end
      end
    end
  end

##########
# GOOGLE #
##########

  describe "with google connect" do
    context "when user not exists" do
      before(:each) do
        mock_omniauth :google
        get :google
        @user = User.where(:email => "google@mail.com").first
      end

      after(:each) do
        @user = User.destroy_all
      end

      it { @user.should_not be_nil }

      it "should create authentication with facebook id" do
        oauth_provider = @user.oauth_providers.where(:provider => "google", :uid => "google_uid").first
        oauth_provider.should_not be_nil
      end

      it { should be_user_signed_in }

      it { response.should redirect_to root_path }
    end

    describe "and user exists" do

      describe "logged in" do
        context "when provider not exists" do
          before(:each) do
            mock_omniauth :google
            @user = FactoryGirl.create(:user)
            sign_in @user
            get :google
          end

          after(:each) do
            User.destroy_all
          end

          it "should create authentication with google id" do
            oauth_provider = @user.oauth_providers.where(:provider => "google", :uid => "google_uid").first
            oauth_provider.should_not be_nil
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }
        end
      end

      describe "not logged in" do
        context "when provider not exists but user email matches" do
          before(:each) do
            mock_omniauth :google
            @user = FactoryGirl.create(:user, :email => 'google@mail.com')
            get :google
          end

          after(:each) do
            User.destroy_all
          end

          it "should create authentication with facebook id" do
            oauth_provider = @user.oauth_providers.where(:provider => "google", :uid => "google_uid").first
            oauth_provider.should_not be_nil
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }
        end

        context "when provider exists" do
          before(:each) do
            mock_omniauth :google
            @user = FactoryGirl.create(:user_with_google)
            get :google
          end

          it { should be_user_signed_in }

          it { response.should redirect_to root_path }

          after(:each) do
            User.destroy_all
          end
        end
      end
    end
  end

end

def mock_omniauth(provider = :facebook)
  # This a Devise specific thing for functional tests. See https://github.com/plataformatec/devise/issues/closed#issue/608
  request.env["devise.mapping"] = Devise.mappings[:user]
  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
end