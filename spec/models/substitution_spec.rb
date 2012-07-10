require 'spec_helper'

describe Substitution do
  describe "when create" do
    context "with correct data" do
      let(:substitution) { create(:substitution) }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player_out }
      its(:second_player_relation) { should eql :player_in }
      its(:player_in) { should have(1).stats }
      its(:player_out) { should have(1).stats }

      context "the player in stats" do
        let(:player_in_stat) { substitution.player_in.stats.season(substitution.game.season).week(substitution.game.week).first }
        subject { player_in_stat }

        its(:points) { should eql Substitution::STATS_IN[:points] }
        its(:games_played) { should eql Substitution::STATS_IN[:games_played] }
        its(:minutes_played) { should eql Player::MAX_MINUTES - substitution.minute }
      end

      context "the player out stats" do
        let(:player_out_stat) { substitution.player_out.stats.season(substitution.game.season).week(substitution.game.week).first }
        subject { player_out_stat }

        its(:minutes_played) { should eql substitution.minute  }
      end

      describe"and update player in" do
        let(:player_in_was) { substitution.player_in }
        let(:player_in_new) { create(:player_with_club, player_club: player_in_was.club) }
        before {  substitution; player_in_was; substitution.update_attributes(player_in: player_in_new) }

        context "the player in was stats" do
          let(:player_in_was_stat) { player_in_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_was_stat }

          its(:points) { should be_zero }
          its(:games_played) { should be_zero }
          its(:minutes_played) { should be_zero }
        end

        context "the player in new stats" do
          let(:player_in_new_stat) { player_in_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_new_stat }

          its(:points) { should eql Substitution::STATS_IN[:points] }
          its(:games_played) { should eql Substitution::STATS_IN[:games_played] }
          its(:minutes_played) { should eql Player::MAX_MINUTES - substitution.minute }
        end
      end

      context "and update player out" do
        let(:player_out_was) { substitution.player_out }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new) }

        context "the player out was stats" do
          let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_was_stat }

          its(:minutes_played) { should eql Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eql substitution.minute }
        end
      end

      context "and update player out and minute" do
        let(:new_minute) { 2 }
        let(:player_out_was) { substitution.player_out }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new, minute: new_minute) }

        context "the player out was stats" do
          let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_was_stat }

          its(:minutes_played) { should eql Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eql new_minute }
        end
      end

      context "and update player out, player_in and minute" do
        let(:new_minute) { 2 }
        let(:player_in_was) { substitution.player_in }
        let(:player_in_new) { create(:player_with_club, player_club: player_in_was.club) }
        let(:player_out_was) { substitution.player_out }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new, player_in: player_in_new, minute: new_minute) }

        context "the player out was stats" do
          let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_was_stat }

          its(:minutes_played) { should eql Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eql new_minute }
        end

        context "the player in was stats" do
          let(:player_in_was_stat) { player_in_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_was_stat }

          its(:minutes_played) { should be_zero }
        end

        context "the player in new stats" do
          let(:player_in_new_stat) { player_in_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_new_stat }

          its(:minutes_played) { should eql Player::MAX_MINUTES - new_minute }
        end
      end

      describe "and destroy" do
        context "the player in stats" do
          let(:player_in) { substitution.player_in }
          let(:player_in_stat) { player_in.stats.season(substitution.game.season).week(substitution.game.week).first }
          before {  player_in; substitution.destroy }
          subject { player_in_stat }

          its(:points) { should be_zero }
          its(:games_played) { should be_zero }
          its(:minutes_played) { should be_zero }
        end

        context "the player out stats" do
          let(:player_out) { substitution.player_out }
          let(:player_out_stat) { player_out.stats.season(substitution.game.season).week(substitution.game.week).first }
          before {  player_out; substitution.destroy }
          subject { player_out_stat }

          its(:points) { should eql Lineup::STATS[:points] }
          its(:games_played) { should eql Lineup::STATS[:games_played] }
          its(:minutes_played) { should eql Player::MAX_MINUTES }
        end
      end
    end

    context "without player in" do
      let(:substitution) { build(:substitution, player_in: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('errors.messages.blank') }
    end

    context "without player in playing" do
      let(:game) { create(:game) }
      let(:player_in_playing) { create(:player_in_game, player_game: game) }
      let(:substitution) { build(:substitution, game: game, player_in: player_in_playing) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_not_play_yet') }
    end
  end
end
