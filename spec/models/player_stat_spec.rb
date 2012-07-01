require 'spec_helper'

describe PlayerStat do
  context "with correct data" do
    let(:player_stat) { create(:player_stat) }
    subject { player_stat }

    it { should be_valid }

    context "when exists another with same player and game" do
      let(:another_player_stat) { build(:player_stat, player: player_stat.player, game: player_stat.game) }
      subject { another_player_stat }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { another_player_stat.error_on(:player_id).should include I18n.t('errors.messages.taken') }
    end

    context "when exists another same player in another game" do
      let(:another_player_stat) { create(:player_stat, player: player_stat.player) }
      subject { another_player_stat }

      it { should be_valid }
    end

    context "when exists another with another player in same week and season" do
      let(:another_player_stat) { create(:player_stat, game: player_stat.game) }
      subject { another_player_stat }

      it { should be_valid }
    end
  end

  context "without player" do
    let(:player_stat) { build(:player_stat, player: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:player_id) }
    it { player_stat.error_on(:player_id).should include I18n.t('errors.messages.blank') }
  end

  context "without game" do
    let(:player_stat) { build(:player_stat, game: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:game_id) }
    it { player_stat.error_on(:game_id).should include I18n.t('errors.messages.blank') }
  end

  context "without points" do
    let(:player_stat) { build(:player_stat, points: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with minute less than -99" do
    let(:player_stat) { build(:player_stat, points: -100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => -99) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with minute greater than 99" do
    let(:player_stat) { build(:player_stat, points: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer minute" do
    let(:player_stat) { build(:player_stat, points: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.not_an_integer') }
  end
end
