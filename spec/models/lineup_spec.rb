require 'spec_helper'

describe Lineup do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.lineup.attributes.player.should_play_in_any_club' }

    context "with correct data" do
      let(:lineup) { create(:lineup) }
      subject { lineup }

      it { should be_valid }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { lineup.player.stats.season(lineup.game.season).week(lineup.game.week).first }
        subject { player_stat }

        its(:points) { should eql Lineup::STATS[:points] }
        its(:lineups) { should eql Lineup::STATS[:lineups] }
        its(:games_played) { should eql Lineup::STATS[:games_played] }
        its(:minutes_played) { should eql Lineup::STATS[:minutes_played] }
      end

      context "and update player" do
        let(:player) { create(:player_with_club, player_club: player_was.club) }
        let(:player_was) { lineup.player }
        before {  lineup; player_was; lineup.update_attributes(player: player) }

        context "the was player" do
          let(:player_was_stats) { player_was.stats.season(lineup.game.season).week(lineup.game.week).first }
          subject { player_was_stats }

          its(:points) { should be_zero }
          its(:lineups) { should be_zero }
        end

        context "the new player" do
          let(:player_stats) { player.stats.season(lineup.game.season).week(lineup.game.week).first }
          subject { player_stats }

          its(:points) { should eql Lineup::STATS[:points] }
          its(:lineups) { should eql Lineup::STATS[:lineups] }
          its(:games_played) { should eql Lineup::STATS[:games_played] }
          its(:minutes_played) { should eql Lineup::STATS[:minutes_played] }
        end
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

      context "and create another with same player" do
        let(:another_lineup) { build(:lineup, game: lineup.game, player: lineup.player) }
        subject { another_lineup }

        it { should_not be_valid }
        it { should have(1).error_on(:player_id) }
        it { another_lineup.error_on(:player_id).should include I18n.t('errors.messages.taken') }
      end
    end

    context "without game" do
      let(:lineup) { build(:lineup) }
      before { lineup.game = nil }
      subject { lineup }

      it { should_not be_valid }
      it { should have(1).error_on(:game_id) }
      it { lineup.error_on(:game_id).should include I18n.t('errors.messages.blank') }
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
