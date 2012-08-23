require 'spec_helper'

describe TeamFile do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }

    context "with correct data" do
      let(:team_file) { create(:team_file) }
      subject { team_file }

      it { should be_valid }
      it { team_file.class.include?(Extensions::PlayerFile).should be_true }
    end

    context "without team" do
      let(:team_file) { build(:team_file, team: nil) }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team_id) }
      it { team_file.error_on(:team_id).should include I18n.t('errors.messages.blank') }
    end

    describe "with another file" do
      let(:only_one_current_error_translation_key) { "#{error_translation_key}.player_id.only_one_curent_file_player" }

      context "of the same player in another team without date_out" do
        let(:first_team_file) { create(:team_file) }
        let(:team_file) { build(:team_file, player: first_team_file.player) }
        subject { team_file }

        it { should be_valid }
      end

      context "of the same player in the same team without date_out" do
        let(:first_team_file) { create(:team_file) }
        let(:team_file) { build(:team_file, player: first_team_file.player, team: first_team_file.team) }
        subject { team_file }

        it { should_not be_valid }
        it { should have(1).error_on(:player_id) }
        it { team_file.error_on(:player_id).should include I18n.t(only_one_current_error_translation_key) }
      end

      context "of the same player in the same team with date_out before date in" do
        let(:first_team_file) { create(:team_file) }
        let(:team_file) { build(:team_file, player: first_team_file.player, team: first_team_file.team, date_in: first_team_file.date_out.next) }
        before { first_team_file.update_attributes(date_out: first_team_file.date_in.next) }
        subject { team_file }

        it { should be_valid }
      end
    end

    context "with more than max files per team" do
      let(:cant_have_more_error_translation_key) { "#{error_translation_key}.team.cant_have_more" }

      let(:team) { create(:team) }
      let(:goalkeepers) { create_list(:team_file, 1, team: team, position: 'goalkeeper') }
      let(:defenders) { create_list(:team_file, 4, team: team, position: 'defender') }
      let(:midfielders) { create_list(:team_file, 4, team: team, position: 'midfielder') }
      let(:forwards) { create_list(:team_file, 2, team: team, position: 'forward') }

      let(:team_file) { build(:team_file, team: team, position: 'defender') }

      before { goalkeepers; defenders; midfielders; forwards }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team) }
      it { team_file.error_on(:team).should include I18n.t(cant_have_more_error_translation_key) }
    end

    context "with money" do
      let(:not_enough_money_error_translation_key) { "#{error_translation_key}.team.not_enough_money" }

      let(:remaining_money) { 10 }
      let(:team) { create(:team) }
      let(:team_file) { build(:team_file, team: team, value: player_value) }

      before { team.stub(:remaining_money).and_return(remaining_money) }
      subject { team_file }

      context "not enough" do
        let(:player_value) { 20 }

        it { should_not be_valid }
        it { should have(1).error_on(:team) }
        it { team_file.error_on(:team).should include I18n.t(not_enough_money_error_translation_key) }
      end

      context "enough" do
        let(:player_value) { 5 }

        it { should be_valid }
      end

      context "exact" do
        let(:player_value) { 10 }

        it { should be_valid }
      end
    end

    context "with more than max positions per team" do
      let(:cant_have_more_positions_error_translation_key) { "#{error_translation_key}.team.cant_have_more_positions" }

      let(:team) { create(:team) }
      let(:position) { 'goalkeeper' }
      let(:team_files) { create_list(:team_file, Team::POSITION_LIMITS[position][:maximun], team: team, position: position) }
      let(:team_file) { build(:team_file, team: team, position: position) }

      before { team_files }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team) }
      it { team_file.error_on(:team).should include I18n.t(cant_have_more_positions_error_translation_key, position: team_file.position.text.downcase.pluralize) }
    end

    context "with more than max clubs per team" do
      let(:cant_have_more_clubs_error_translation_key) { "#{error_translation_key}.team.cant_have_more_clubs" }

      let(:team) { create(:team) }
      let(:club) { create(:club) }
      let(:team_files) { create_list(:team_file, Team::MAX_FILES_PER_CLUB, team: team, club: club) }
      let(:team_file) { build(:team_file, team: team, club: club) }

      before { team_files }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team) }
      it { team_file.error_on(:team).should include I18n.t(cant_have_more_clubs_error_translation_key, club: club.name.capitalize) }
    end

    context "with more than max no eu per team" do
      let(:cant_have_more_no_eu_error_translation_key) { "#{error_translation_key}.team.cant_have_more_no_eu" }

      let(:team) { create(:team) }
      let(:club) { create(:club) }
      let(:team_files) { create_list(:team_file, Team::MAX_FILES_NO_EU, team: team) }
      let(:team_file) { build(:team_file, team: team, club: club) }

      before do
       team_files.each { |file| file.player.update_attributes(eu: false)}
       team_file.player.update_attributes(eu: false)
      end
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team) }
      it { team_file.error_on(:team).should include I18n.t(cant_have_more_no_eu_error_translation_key) }
    end

    context "with played player" do
      let(:cant_be_played_error_translation_key) { "#{error_translation_key}.player.cant_be_played" }

      let(:player) { create(:player) }
      let(:team_file) { build(:team_file, player: player) }

      before { team_file; player.stub(:played?).and_return(true) }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { team_file.error_on(:player).should include I18n.t(cant_be_played_error_translation_key) }
    end
  end
end
