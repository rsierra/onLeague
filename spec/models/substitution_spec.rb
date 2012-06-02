require 'spec_helper'

describe Substitution do
  describe "when create" do
    context "with correct data" do
      let(:substitution) { create(:substitution) }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player_out }
    end

    context "without player in" do
      let(:substitution) { build(:substitution, player_in: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(2).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('errors.messages.blank') }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_play_in_any_club') }
    end

    context "with a player in who does not play in the game" do
      let(:player_not_play) { create(:player) }
      let(:substitution) { build(:substitution, player_in: player_not_play) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(2).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_play_in_any_club') }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_be_in_same_club') }
    end

    context "without minute" do
      let(:substitution) { build(:substitution, minute: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(2).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.blank') }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with minute less than 0" do
      let(:substitution) { build(:substitution, minute: -1) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
    end

    context "with minute greater than 130" do
      let(:substitution) { build(:substitution, minute: 131) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
    end

    context "with not integer minute" do
      let(:substitution) { build(:substitution, minute: 10.1) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "with a player in who does not play in the same club than the player out" do
      let(:substitution) { build(:substitution) }
      let(:player_in) { create(:player_with_club, player_club: substitution.game.club_away) }
      before { substitution.player_in = player_in }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_be_in_same_club') }
    end

    context "with the player out as player in" do
      let(:substitution) { build(:substitution) }
      before { substitution.player_in = substitution.player_out }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_be_diferent') }
    end
  end
end
