require 'spec_helper'

describe User do
  describe "check if #has_provider?" do
    context "with facebook provider" do
      before { @user = FactoryGirl.create(:user_with_facebook)}
      subject { @user }
      it { should be_has_provider 'facebook' }
      it { should_not be_has_provider 'google'}
      it { should_not be_has_provider 'twitter' }
    end

    context "with google provider" do
      before { @user = FactoryGirl.create(:user_with_google)}
      subject { @user }
      it { should_not be_has_provider 'facebook' }
      it { should be_has_provider 'google'}
      it { should_not be_has_provider 'twitter' }
    end

    context "with twitter provider" do
      before { @user = FactoryGirl.create(:user_with_twitter)}
      subject { @user }
      it { should_not be_has_provider 'facebook' }
      it { should_not be_has_provider 'google'}
      it { should be_has_provider 'twitter' }
    end
  end
end
