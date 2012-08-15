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
      let(:team_files) { create_list(:team_file, TeamFile::MAX_FILES, team: team) }
      let(:team_file) { build(:team_file, team: team) }

      before { team_files }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team) }
      it { team_file.error_on(:team).should include I18n.t(cant_have_more_error_translation_key) }
    end
  end
end
