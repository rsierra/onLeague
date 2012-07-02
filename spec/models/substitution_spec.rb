require 'spec_helper'

describe Substitution do
  describe "when create" do
    context "with correct data" do
      let(:substitution) { create(:substitution) }
      let(:player_in_stat) { substitution.player_in.stats.season(substitution.game.season).week(substitution.game.week).first }
      let(:player_out_stat) { substitution.player_out.stats.season(substitution.game.season).week(substitution.game.week).first }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player_out }
      its(:second_player_relation) { should eql :player_in }
      its(:player_in) { should have(1).stats }
      it { player_in_stat.points.should eql Substitution::STATS_IN[:points] }
      it { player_in_stat.games_played.should eql Substitution::STATS_IN[:games_played] }
      it { player_in_stat.minutes_played.should eql Player::MAX_MINUTES - substitution.minute }
      its(:player_out) { should have(1).stats }
      it { player_out_stat.minutes_played.should eql substitution.minute  }

      context "and update player in" do
        let(:player_in_was) { substitution.player_in }
        let(:player_in_was_stat) { player_in_was.stats.season(substitution.game.season).week(substitution.game.week).first }
        let(:player_in_new) { create(:player_with_club, player_club: player_in_was.club) }
        let(:player_in_new_stat) { player_in_new.stats.season(substitution.game.season).week(substitution.game.week).first }
        before {  substitution; player_in_was; substitution.update_attributes(player_in: player_in_new) }

        it { player_in_was_stat.points.should be_zero }
        it { player_in_was_stat.games_played.should be_zero }
        it { player_in_was_stat.minutes_played.should be_zero }
        it { player_in_new_stat.points.should eql Substitution::STATS_IN[:points] }
        it { player_in_new_stat.games_played.should eql Substitution::STATS_IN[:games_played] }
        it { player_in_new_stat.minutes_played.should eql Player::MAX_MINUTES - substitution.minute }
      end

      context "and update player out" do
        let(:player_out_was) { substitution.player_out }
        let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new) }

        it { player_out_was_stat.minutes_played.should eql Player::MAX_MINUTES }
        it { player_out_new_stat.minutes_played.should eql substitution.minute }
      end

      context "and update player out, player_in and minute" do
        let(:new_minute) { 2 }
        let(:player_in_was) { substitution.player_in }
        let(:player_in_was_stat) { player_in_was.stats.season(substitution.game.season).week(substitution.game.week).first }
        let(:player_in_new) { create(:player_with_club, player_club: player_in_was.club) }
        let(:player_in_new_stat) { player_in_new.stats.season(substitution.game.season).week(substitution.game.week).first }
        let(:player_out_was) { substitution.player_out }
        let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new, player_in: player_in_new, minute: new_minute) }

        it { player_out_was_stat.minutes_played.should eql Player::MAX_MINUTES }
        it { player_out_new_stat.minutes_played.should eql new_minute }
        it { player_in_was_stat.minutes_played.should be_zero }
        it { player_in_new_stat.minutes_played.should eql Player::MAX_MINUTES - new_minute }
      end
    end

    context "without player in" do
      let(:substitution) { build(:substitution, player_in: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(2).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('errors.messages.blank') }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_not_play_yet') }
    end
  end
end
