require 'spec_helper'

describe TeamFile do
  describe "when create" do
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

    context "with more than max files per team" do
      let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }
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
      let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }
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
      let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }
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
      let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }
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
      let(:error_translation_key) { 'activerecord.errors.models.team_file.attributes' }
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
  end
end
