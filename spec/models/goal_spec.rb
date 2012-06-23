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

    context "without assistant and no regular" do
      let(:goal) { build(:goal, kind: Goal.kind.values.last) }
      subject { goal }

      it { should be_valid }
    end

    context "with assistant in a no regular" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_with_club, player_club: game.club_home) }
      let(:assistant) { create(:player_with_club, player_club: game.club_home) }
      let(:goal) { build(:goal, game: game, scorer: scorer, assistant: assistant, kind: Goal.kind.values.last) }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:assistant) }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_not_be') }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_be_playing') }
    end
  end
end
