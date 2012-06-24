require 'spec_helper'

describe League do
  describe "when create" do
    context "with correct data" do
      let(:league) { build(:league) }
      subject { league }

      it { should be_valid }
    end

    context "without name" do
      let(:league) { build(:league, name: nil) }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { league.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with duplicate name" do
      let(:league) { build(:league, name: "League name") }
      before { create(:league, name: "League name") }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { league.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without week" do
      let(:league) { build(:league, week: nil) }
      subject { league }

      it { should_not be_valid }
      it { should have(3).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.blank') }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:week).should include I18n.t('errors.messages.too_short', count: 1) }
    end

    context "with too long week" do
      let(:league) { build(:league, week: 111) }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.too_long', count: 2) }
    end

    context "with string week" do
      let(:league) { build(:league, week: 'a') }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with float week" do
      let(:league) { build(:league, week: '.1') }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "without season" do
      let(:league) { build(:league, season: nil) }
      subject { league }

      it { should_not be_valid }
      it { should have(3).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.blank') }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with too long season" do
      let(:league) { build(:league, season: 11111) }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with too short season" do
      let(:league) { build(:league, season: 111) }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with string season" do
      let(:league) { build(:league, season: 'a') }
      subject { league }

      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with float season" do
      let(:league) { build(:league, season: '1111.1') }
      subject { league }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_an_integer') }
    end
  end

  context "when get active" do
    let(:league_active) { create(:league) }
    let(:league_inactive) { create(:league, active: false) }

    before { league_active; league_inactive }

    it { League.active.should == [league_active] }
  end

  context "when get all except one" do
    let(:league) { create(:league) }
    let(:second_league) { create(:league, active: false) }

    before { league; second_league }

    it { League.except(second_league).should == [league] }
    it { League.except(league).should == [second_league] }
  end
end
