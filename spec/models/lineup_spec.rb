require 'spec_helper'

describe Lineup do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.lineup.attributes.player.should_play_in_any_club' }

    context "with correct data" do
      let(:lineup) { create(:lineup) }
      subject { lineup }

      it { should be_valid }
    end

    context "without game" do
      let(:lineup) { build(:lineup) }
      before { lineup.game = nil }
      subject { lineup }

      it { should_not be_valid }
      it { should have(1).error_on(:game) }
      it { lineup.error_on(:game).should include I18n.t('errors.messages.blank') }
    end

    context "without player" do
      let(:lineup) { build(:lineup, player: nil) }
      subject { lineup }

      it { should_not be_valid }
      it { should have(2).error_on(:player) }
      it { lineup.error_on(:player).should include I18n.t('errors.messages.blank') }
      it { lineup.error_on(:player).should include I18n.t(error_translation_key) }
    end

    context "with a player who does not play in the game" do
      let(:player_not_play) { create(:player) }
      let(:lineup) { build(:lineup, player: player_not_play) }
      subject { lineup }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { lineup.error_on(:player).should include I18n.t(error_translation_key) }
    end
  end
end
