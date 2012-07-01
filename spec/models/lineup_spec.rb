require 'spec_helper'

describe Lineup do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.lineup.attributes.player.should_play_in_any_club' }

    context "with correct data" do
      let(:lineup) { create(:lineup) }
      subject { lineup }

      it { should be_valid }
      its(:player) { should have(1).stats }
      it { lineup.player.stats.first.points.should eql Lineup::STATS[:points] }
      it { lineup.player.stats.first.lineups.should eql Lineup::STATS[:lineups] }
      it { lineup.player.stats.first.games_played.should eql Lineup::STATS[:games_played] }
      it { lineup.player.stats.first.minutes_played.should eql Lineup::STATS[:minutes_played] }

      context "and update player" do
        let(:player) { create(:player_with_club, player_club: player_was.club) }
        let(:player_was) { lineup.player }
        before {  lineup; player_was; lineup.update_attributes(player: player) }

        it { player_was.stats.season(lineup.game.season).week(lineup.game.week).first.points.should be_zero }
        it { player_was.stats.season(lineup.game.season).week(lineup.game.week).first.lineups.should be_zero }
        it { player.stats.season(lineup.game.season).week(lineup.game.week).first.points.should eql Lineup::STATS[:points] }
        it { player.stats.season(lineup.game.season).week(lineup.game.week).first.lineups.should eql Lineup::STATS[:lineups] }
        it { player.stats.season(lineup.game.season).week(lineup.game.week).first.games_played.should eql Lineup::STATS[:games_played] }
        it { player.stats.season(lineup.game.season).week(lineup.game.week).first.minutes_played.should eql Lineup::STATS[:minutes_played] }
      end

      context "and then destroy" do
        let(:player) { lineup.player }
        before {  player; lineup.destroy }
        subject { player.stats.season(lineup.game.season).week(lineup.game.week).first }

        its(:points) { should be_zero }
        its(:lineups) { should be_zero }
        its(:games_played) { should be_zero }
        its(:minutes_played) { should be_zero }
      end
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
