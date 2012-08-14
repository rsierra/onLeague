require 'spec_helper'

describe User do
  describe "check if #has_provider?" do
    context "with facebook provider" do
      let(:user) { create(:user_with_facebook) }
      subject { user }
      it { should be_has_provider 'facebook' }
      it { should_not be_has_provider 'google'}
      it { should_not be_has_provider 'twitter' }
    end

    context "with google provider" do
      let(:user) { create(:user_with_google) }
      subject { user }
      it { should_not be_has_provider 'facebook' }
      it { should be_has_provider 'google'}
      it { should_not be_has_provider 'twitter' }
    end

    context "with twitter provider" do
      let(:user) { create(:user_with_twitter) }
      subject { user }
      it { should_not be_has_provider 'facebook' }
      it { should_not be_has_provider 'google'}
      it { should be_has_provider 'twitter' }
    end
  end

  describe "when #apply_omniauth" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:provider, {
      info: {name: 'Provider Name', nickname: 'provider_nick', email: 'provider@mail.com' },
      uid: 'provider_uid'
    })

    context "with new user" do
      let(:omniauth) { OmniAuth.config.mock_auth[:provider] }
      let(:user) { User.new }
      before { user.apply_omniauth(omniauth) }
      let(:provider) { user.oauth_providers.first }

      subject { user }

      its(:email) { should == omniauth.info.email }
      its(:name) { should == omniauth.info.name }
      its(:confirmed_at) { should_not be_nil }
      it { should have(1).oauth_providers }
      it { provider.provider.should == omniauth.provider }
      it { provider.uemail.should == omniauth.info.email }
      it { provider.uname.should == omniauth.info.name }
    end

    context "with exist user" do
      let(:omniauth) { OmniAuth.config.mock_auth[:provider] }
      let(:user) { create(:user) }
      before { user.apply_omniauth(omniauth) }
      let(:email) { user.email }
      let(:name) { user.name }
      let(:provider) { user.oauth_providers.first }

      subject { user }

      its(:email) { should == email }
      its(:name) { should == name }
      it { should have(1).oauth_providers }
      it { provider.provider.should == omniauth.provider }
      it { provider.uemail.should == omniauth.info.email }
      it { provider.uname.should == omniauth.info.name }
    end
  end

  context "when get latest" do
    let(:users) { create_list(:user, 20).sort {|x,y| y.created_at <=> x.created_at } }

    before { users }

    it { User.latest.should == users.first(10) }
    it { User.latest(1).should == users.first(1) }
    it { User.latest(5).should == users.first(5) }
    it { User.latest(15).should == users.first(15) }
    it { User.latest(20).should == users }
    it { User.latest(25).should == users }
  end

  context "when get remaining teams in league" do
    let(:user) { create(:user) }
    let(:league) { create(:league) }

    subject { user.remaining_teams_in_league league }

    it { should eq 2 }
    it { should eq Team::MAX_TEAMS }

    context "with some team" do
      let(:team) { create(:team, user: user, league: league) }
      before { team }

      it { should eq 1 }
      it { should eq Team::MAX_TEAMS - 1 }
    end
  end
end
