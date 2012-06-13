require 'spec_helper'

describe Goal do
  describe "when create" do
    context "with correct data" do
      let(:goal) { create(:goal) }
      subject { goal }

      it { should be_valid }
      it { goal.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :scorer }
      its(:second_player_relation) { should eql :assistant }
    end

    context "without kind" do
      let(:goal) { build(:goal, kind: nil) }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:kind) }
      it { goal.error_on(:kind).should include I18n.t('errors.messages.blank') }
      it { goal.error_on(:kind).should include I18n.t('errors.messages.inclusion') }
    end
  end
end
