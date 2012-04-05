require 'spec_helper'

describe Users::OmniauthCallbacksController, "handle omniauth authentication callback" do

  OmniAuth.config.test_mode = true

  ############
  # FACEBOOK #
  ############

  describe "with facebook connect" do
    let(:provider) { 'facebook' }
    let(:uid) { 'facebook_uid' }
    let(:email) { 'facebook@mail.com' }
    let(:name) { 'Facebook Name' }

    OmniAuth.config.add_mock(:facebook, {
      info: { email: 'facebook@mail.com', name: 'Facebook Name', nickname: 'facebook_nick'},
      uid: 'facebook_uid'
    })

    before { mock_omniauth :facebook }

    context "when user not exists" do
      before { get :facebook }
      let(:user) { User.where(email: email).first }

      it { user.should_not be_nil }
      it "should create authentication with facebook id" do
        oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
        oauth_provider.should_not be_nil
      end
      it { should be_user_signed_in }
      it { response.should redirect_to root_path }
      it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.user_created', provider: provider) }
    end

    describe "and user exists" do

      describe "logged in" do
        context "when provider not exists" do
          let(:user) { FactoryGirl.create(:user) }
          before { sign_in user; get :facebook }

          it "should create authentication with facebook id" do
            oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
            oauth_provider.should_not be_nil
          end
          it { should be_user_signed_in }
          it { response.should redirect_to edit_user_registration_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_linked', provider: provider) }
        end
      end

      describe "not logged in" do
        context "when provider not exists but user email matches" do
          let(:user) { FactoryGirl.create(:user, email: email) }
          before { user; get :facebook }

          it "should create authentication with facebook id" do
            oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
            oauth_provider.should_not be_nil
          end
          it { should be_user_signed_in }
          it { response.should redirect_to edit_user_registration_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_linked', provider: provider) }
        end

        context "when provider exists" do
          let(:user) { FactoryGirl.create(:user_with_facebook) }
          before { user; get :facebook }

          it { should be_user_signed_in }
          it { response.should redirect_to root_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_success', provider: provider) }
        end
      end
    end
  end

##########
# GOOGLE #
##########

  describe "with google connect" do
    let(:provider) { 'google' }
    let(:uid) { 'google_uid' }
    let(:email) { 'google@mail.com' }
    let(:name) { 'Google Name' }

    OmniAuth.config.add_mock(:google, {
      info: { email: 'google@mail.com', name: 'Google Name', nickname: 'google_nick'},
      uid: 'google_uid'
    })

    before { mock_omniauth :google }

    context "when user not exists" do
      before { get :google }
      let(:user) { User.where(email: email).first }

      it { user.should_not be_nil }
      it "should create authentication with facebook id" do
        oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
        oauth_provider.should_not be_nil
      end
      it { should be_user_signed_in }
      it { response.should redirect_to root_path }
      it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.user_created', provider: provider) }
    end

    describe "and user exists" do

      describe "logged in" do
        context "when provider not exists" do
          let(:user) { FactoryGirl.create(:user) }
          before { sign_in user; get :google }

          it "should create authentication with google id" do
            oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
            oauth_provider.should_not be_nil
          end
          it { should be_user_signed_in }
          it { response.should redirect_to edit_user_registration_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_linked', provider: provider) }
        end
      end

      describe "not logged in" do
        context "when provider not exists but user email matches" do
          let(:user) { FactoryGirl.create(:user, email: email) }
          before { user; get :google }

          it "should create authentication with facebook id" do
            oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
            oauth_provider.should_not be_nil
          end
          it { should be_user_signed_in }
          it { response.should redirect_to edit_user_registration_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_linked', provider: provider) }
        end

        context "when provider exists" do
          let(:user) { FactoryGirl.create(:user_with_google) }
          before { user; get :google }

          it { should be_user_signed_in }
          it { response.should redirect_to root_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_success', provider: provider) }
        end
      end
    end
  end

###########
# TWITTER #
###########

  describe "with twitter connect" do
    let(:provider) { 'twitter' }
    let(:uid) { 'twitter_uid' }
    let(:email) { 'twitter@mail.com' }
    let(:name) { 'Twitter Name' }

    OmniAuth.config.add_mock(:twitter, {
      info: {name: 'Twitter Name', nickname: 'twitter_nick'},
      uid: 'twitter_uid'
    })

    before { mock_omniauth :twitter }

    context "when user not exists" do
      before { get :twitter }
      let(:user) { User.where(email: email).first }

      it { user.should be_nil }
      it { should_not be_user_signed_in }
      it { response.should redirect_to new_user_registration_path }
      it { flash[:alert].should == I18n.t('devise.omniauth_callbacks.no_email', provider: provider.capitalize) }
    end

    describe "and user exists" do

      describe "logged in" do
        context "when provider not exists" do
          let(:user) { FactoryGirl.create(:user) }
          before { sign_in user; get :twitter }

          it "should create authentication with twitter id" do
            oauth_provider = user.oauth_providers.where(provider: provider, uid: uid).first
            oauth_provider.should_not be_nil
          end
          it { should be_user_signed_in }
          it { response.should redirect_to edit_user_registration_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_linked', provider: provider) }
        end
      end

      describe "not logged in" do
        context "when provider exists" do
          let(:user) { FactoryGirl.create(:user_with_twitter) }
          before { user; get :twitter }

          it { should be_user_signed_in }
          it { response.should redirect_to root_path }
          it { flash[:notice].should == I18n.t('devise.omniauth_callbacks.provider_success', provider: provider) }
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