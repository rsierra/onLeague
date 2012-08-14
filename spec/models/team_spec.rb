require 'spec_helper'

describe Team do
  describe "when create" do
    context "with correct data" do
      let(:team) { build(:team) }
      before { team.valid? }
      subject { team }

      it { should be_valid }
      its(:season) { should eq team.league.season }
      its(:money) { should eq 200 }
      its(:money) { should eq Team::INITIAL_MONEY }

    end

    context "without user" do
      let(:team) { build(:team, user: nil) }
      subject { team }

      it { should_not be_valid }
      it { should have(1).error_on(:user) }
      it { team.error_on(:user).should include I18n.t('errors.messages.blank') }
    end

    context "without league" do
      let(:team) { build(:team, league: nil) }
      subject { team }

      it { should_not be_valid }
      it { should have(1).error_on(:league) }
      it { team.error_on(:league).should include I18n.t('errors.messages.blank') }
    end

    context "without name" do
      let(:team) { build(:team, name: nil) }
      subject { team }

      it { should_not be_valid }
      it { should have(2).error_on(:name) }
      it { team.error_on(:name).should include I18n.t('errors.messages.blank') }
      it { team.error_on(:name).should include I18n.t('errors.messages.too_short', count: 3) }
    end

    context "with too long name" do
      let(:team) { build(:team, name: "A name more long than a 25 characters") }
      subject { team }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { team.error_on(:name).should include I18n.t('errors.messages.too_long', count: 25) }
    end

    context "with too short name" do
      let(:team) { build(:team, name: "na") }
      subject { team }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { team.error_on(:name).should include I18n.t('errors.messages.too_short', count: 3) }
    end

    context "with duplicate name in same league and season" do
      let(:season) { 2000 }
      let(:league) { create(:league) }
      let(:team) { build(:team, league: league, season: season, name: "Club name") }
      before { create(:team, league: league, season: season, name: "Club name") }
      subject { team }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { team.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "with duplicate name in same league but diferent season" do
      let(:league) { create(:league) }
      let(:team) { build(:team, league: league, season: 2000, name: "Club name") }
      before { create(:team, league: league, season: 2001, name: "Club name") }
      subject { team }

      it { should be_valid }
    end

    context "with duplicate name in same season but diferent league" do
      let(:team) { build(:team, season: 2000, name: "Club name") }
      before { create(:team, season: 2000, name: "Club name") }
      subject { team }

      it { should be_valid }
    end

    describe "more than max teams per user"do
      let(:error_translation_key) { 'activerecord.errors.models.team.attributes' }
      let(:cant_have_more_error_translation_key) { "#{error_translation_key}.user.cant_have_more" }

      let(:league) { create(:league) }
      let(:user) { create(:user) }
      let(:teams) { create_list(:team, Team::MAX_TEAMS, user: user, league: league) }

      context "in same league and season" do
        let(:team) { build(:team, user: user, league: league) }
        before { teams }
        subject { team }

        it { should_not be_valid }
        it { should have(1).error_on(:user) }
        it { team.error_on(:user).should include I18n.t(cant_have_more_error_translation_key) }
      end

      context "in same league and another season" do
        let(:team) { build(:team, user: user, league: league) }
        before { teams; league.update_attributes(season: league.season + 1) }
        subject { team }

        it { should be_valid }
      end

      context "in another league" do
        let(:team) { build(:team, user: user) }
        before { teams }
        subject { team }

        it { should be_valid }
      end
    end
  end

  context "when activate" do
    let(:team) { build(:team) }
    before { team.activate }
    subject { team }

    its(:active) { should be_true }
    its(:activation_week) { should eq team.league.week }
  end
end
