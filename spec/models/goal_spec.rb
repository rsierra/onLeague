require 'spec_helper'

describe Goal do
  describe "when create" do
    context "with correct data" do
      let(:goal) { create(:goal) }
      subject { goal }

      it { should be_valid }
      it { goal.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :scorer }
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

    context "with a valid assistant" do
      let(:goal) { build(:goal) }
      let(:assistant) { create(:player_with_club, player_club: goal.scorer.club) }
      before { goal.assistant = assistant }
      subject { goal }

      it { should be_valid }
    end

    context "with a assistant who does not play in the game" do
      let(:goal) { build(:goal) }
      let(:assistant) { create(:player) }
      before { goal.assistant = assistant }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:assistant) }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_play_in_any_club') }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_be_in_same_club') }
    end

    context "with a assistant who does not play in the same club than the scorer" do
      let(:goal) { build(:goal) }
      let(:assistant) { create(:player_with_club, player_club: goal.game.club_away) }
      before { goal.assistant = assistant }
      subject { goal }

      it { should_not be_valid }
      it { should have(1).error_on(:assistant) }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_be_in_same_club') }
    end

    context "with the scorer as assistant" do
      let(:goal) { build(:goal) }
      before { goal.assistant = goal.scorer }
      subject { goal }

      it { should_not be_valid }
      it { should have(1).error_on(:assistant) }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_be_diferent') }
    end
  end
end
