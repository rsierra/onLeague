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

  context "when get teams of a league on a season" do
    let(:league_one) { create(:league) }
    let(:teams) { create_list(:team, 3, league: league_one).sort }
    let(:league_two) { create(:league) }
    let(:team) { create(:team, league: league_two) }
    let(:league_empty) { create(:league) }
    before { teams; team }

    it { Team.of_league_season(league_one).sort.should eq teams }
    it { Team.of_league_season(league_two).should eq [team] }
    it { Team.of_league_season(league_empty).should be_empty }

    context "with team in another season" do
      let(:team_another_season) { create(:team, league: league_one) }

      before do
        teams; team
        league_one.update_attributes(season: league_one.season + 1)
        team_another_season
      end

      it { Team.of_league_season(league_one).should eq [team_another_season] }
      it { Team.of_league_season(league_one, league_one.season - 1).sort.should eq teams }
    end
  end

  context "when get remaining files" do
    let(:team) { create(:team) }
    subject { team }

    its(:remaining_files) { should eq 11 }
    its(:remaining_files) { should eq Team::MAX_FILES }

    context "with a current file" do
      let(:team_file) { create(:team_file, team: team) }
      before { team_file }

      its(:remaining_files) { should eq 10 }
      its(:remaining_files) { should eq Team::MAX_FILES - 1 }
    end

    context "with some current files" do
      let(:files_number) { 4 }
      let(:team_files) { create_list(:team_file, files_number,team: team) }
      before { team_files }

      its(:remaining_files) { should eq 11 - files_number }
      its(:remaining_files) { should eq Team::MAX_FILES - files_number }
    end

    context "with a file closed" do
      let(:team_file) { create(:team_file, team: team) }
      before { team_file.update_attributes(date_out: team_file.date_in.next) }

      its(:remaining_files) { should eq 11 }
      its(:remaining_files) { should eq Team::MAX_FILES }
    end
  end

  describe "when get number of" do
    let(:team) { create(:team) }
    subject { team }

    context "goalkeepers" do
      its(:goalkeepers_count) { should be_zero }

      context "with goalkeepers" do
        let(:team_file) { create(:team_file, team: team, position: :goalkeeper) }
        before { team_file }

        its(:goalkeepers_count) { should eq 1 }
      end
    end

    context "defenders" do
      its(:defenders_count) { should be_zero }

      context "with defenders" do
        let(:team_file) { create(:team_file, team: team, position: :defender) }
        before { team_file }

        its(:defenders_count) { should eq 1 }
      end
    end

    context "midfielders" do
      its(:midfielders_count) { should be_zero }

      context "with midfielders" do
        let(:team_file) { create(:team_file, team: team, position: :midfielder) }
        before { team_file }

        its(:midfielders_count) { should eq 1 }
      end
    end

    context "forwards" do
      its(:forwards_count) { should be_zero }

      context "with forwards" do
        let(:team_file) { create(:team_file, team: team, position: :forward) }
        before { team_file }

        its(:forwards_count) { should eq 1 }
      end
    end
  end

  describe "when valid minimums" do
    let(:team) { create(:team) }
    before do
      team.stub(:remaining_files).and_return(remaining_files)
      team.stub(:needed_position).with('goalkeeper').and_return(1)
      team.stub(:needed_position).with('defender').and_return(0)
      team.stub(:needed_position).with('midfielder').and_return(0)
      team.stub(:needed_position).with('forward').and_return(0)
    end

    describe "with enough remaining files, not minimum at one position" do
      let(:remaining_files) { 2 }

      context "and check this position" do
        let(:position) { 'goalkeeper' }
        subject { team.valid_minimums? position }

        it { should be_true }
      end

      context "and check another" do
        let(:position) { 'defender' }
        subject { team.valid_minimums? position }

        it { should be_true }
      end
    end

    describe "without enough remaining files, not minimum at one position" do
      let(:remaining_files) { 1 }

      context "and check this position" do
        let(:position) { 'goalkeeper' }
        subject { team.valid_minimums? position }

        it { should be_true }
      end

      context "and check another" do
        let(:position) { 'defender' }
        subject { team.valid_minimums? position }

        it { should be_false }
      end
    end
  end
end
