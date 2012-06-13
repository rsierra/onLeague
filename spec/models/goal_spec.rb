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

    context "without minute" do
      let(:goal) { build(:goal, minute: nil) }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:minute) }
      it { goal.error_on(:minute).should include I18n.t('errors.messages.blank') }
      it { goal.error_on(:minute).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with minute less than 0" do
      let(:goal) { build(:goal, minute: -1) }
      subject { goal }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { goal.error_on(:minute).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
    end

    context "with minute greater than 130" do
      let(:goal) { build(:goal, minute: 131) }
      subject { goal }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { goal.error_on(:minute).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
    end

    context "with not integer minute" do
      let(:goal) { build(:goal, minute: 10.1) }
      subject { goal }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { goal.error_on(:minute).should include I18n.t('errors.messages.not_an_integer') }
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
