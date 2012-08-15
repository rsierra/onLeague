require 'spec_helper'

describe TeamFile do
  describe "when create" do
    context "with correct data" do
      let(:team_file) { create(:team_file) }
      subject { team_file }

      it { should be_valid }
      it { goal.class.include?(Extensions::PlayerFile).should be_true }
    end

    context "without team" do
      let(:team_file) { build(:team_file, team: nil) }
      subject { team_file }

      it { should_not be_valid }
      it { should have(1).error_on(:team_id) }
      it { team_file.error_on(:team_id).should include I18n.t('errors.messages.blank') }
    end
  end
end
