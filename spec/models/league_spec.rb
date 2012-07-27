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

  context "when get current games" do
    let(:league) { create(:league) }
    let(:game) { create(:game, league: league) }
    let(:next_game) { create(:game, league: league, week: game.week + 1) }

    before { league.update_attributes(season: game.season, week: game.week) }
    subject { league }

    it { should have(1).current_games }
    its(:current_games) { should include game}

    context "with more than one game" do
      let(:another_game) { create(:game, league: league) }

      before { another_game }

      it { should have(2).current_games }
      its(:current_games) { should include game}
      its(:current_games) { should include another_game}
    end
  end

  describe "when check if week is closeable" do
    let(:league) { create(:league) }
    let(:game) { create(:game, league: league) }

    before { league.update_attributes(season: game.season, week: game.week) }
    subject { league }

    context "with an active game" do
      its(:week_closeable?) { should be_false }
    end

    context "with an inactive game" do
      before { game.update_attributes(status: 'inactive') }

      its(:week_closeable?) { should be_true }
    end

    context "with an evaluated game" do
      before { game.update_attributes(status: 'evaluated') }

      its(:week_closeable?) { should be_false }
    end

    context "with an revised game" do
      before { game.update_attribute(:status, 'revised') }

      its(:week_closeable?) { should be_true }
    end

    context "with a closed game" do
      before { game.update_attribute(:status, 'closed') }

      its(:week_closeable?) { should be_true }
    end

    context "with a closeable game" do
      let(:closeable_game) { create(:game, league: league) }
      before { closeable_game.update_attribute(:status, 'revised') }

      context "and an active game" do
        its(:week_closeable?) { should be_false }
      end

      context "and an inactive game" do
        before { game.update_attributes(status: 'inactive') }

        its(:week_closeable?) { should be_true }
      end

      context "and an evaluated game" do
        before { game.update_attributes(status: 'evaluated') }

        its(:week_closeable?) { should be_false }
      end

      context "and an revised game" do
        before { game.update_attribute(:status, 'revised') }

        its(:week_closeable?) { should be_true }
      end

      context "and a closed game" do
        before { game.update_attribute(:status, 'closed') }

        its(:week_closeable?) { should be_true }
      end
    end
  end
end
