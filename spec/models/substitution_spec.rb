require 'spec_helper'

describe Substitution do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.substitution.attributes' }
    let(:not_play_yet_error_translation_key) { "#{error_translation_key}.player_in.should_not_play_yet" }
    let(:cant_have_more_substitutions_error_translation_key) { "#{error_translation_key}.game.cant_have_more" }

    context "with correct data" do
      let(:substitution) { create(:substitution) }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:max_per_game) { should eq 3 }
      its(:player_relation) { should eq :player_out }
      its(:second_player_relation) { should eq :player_in }
      its(:player_in) { should have(1).stats }
      its(:player_out) { should have(1).stats }

      context "the player in stats" do
        let(:player_in_stat) { substitution.player_in.stats.season(substitution.game.season).week(substitution.game.week).first }
        subject { player_in_stat }

        its(:points) { should eq Substitution::STATS_IN[:points] }
        its(:games_played) { should eq Substitution::STATS_IN[:games_played] }
        its(:minutes_played) { should eq Player::MAX_MINUTES - substitution.minute }
      end

      context "the player out stats" do
        let(:player_out_stat) { substitution.player_out.stats.season(substitution.game.season).week(substitution.game.week).first }
        subject { player_out_stat }

        its(:minutes_played) { should eq substitution.minute  }
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

          its(:points) { should eq Substitution::STATS_IN[:points] }
          its(:games_played) { should eq Substitution::STATS_IN[:games_played] }
          its(:minutes_played) { should eq Player::MAX_MINUTES - substitution.minute }
        end
      end

      context "and update player out" do
        let(:player_out_was) { substitution.player_out }
        let(:player_out_new) { create(:player_in_game, player_game: substitution.game) }
        before { substitution; player_out_was; substitution.update_attributes(player_out: player_out_new) }

        context "the player out was stats" do
          let(:player_out_was_stat) { player_out_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_was_stat }

          its(:minutes_played) { should eq Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eq substitution.minute }
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

          its(:minutes_played) { should eq Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eq new_minute }
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

          its(:minutes_played) { should eq Player::MAX_MINUTES }
        end

        context "the player out new stats" do
          let(:player_out_new_stat) { player_out_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_out_new_stat }

          its(:minutes_played) { should eq new_minute }
        end

        context "the player in was stats" do
          let(:player_in_was_stat) { player_in_was.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_was_stat }

          its(:minutes_played) { should be_zero }
        end

        context "the player in new stats" do
          let(:player_in_new_stat) { player_in_new.stats.season(substitution.game.season).week(substitution.game.week).first }
          subject { player_in_new_stat }

          its(:minutes_played) { should eq Player::MAX_MINUTES - new_minute }
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

          its(:points) { should eq Lineup::STATS[:points] }
          its(:games_played) { should eq Lineup::STATS[:games_played] }
          its(:minutes_played) { should eq Player::MAX_MINUTES }
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
      it { substitution.error_on(:player_in).should include I18n.t(not_play_yet_error_translation_key) }
    end

    context "more than max substitutions for a game" do
      let(:max_substitutions) { Substitution.max_per_game }
      let(:game) { create(:game) }
      let(:players_out) { create_list(:player_in_game, max_substitutions + 1, player_game: game) }
      let(:players_in) { create_list(:player_with_club, max_substitutions + 1, player_club: game.club_home) }
      let(:substitution) { build(:substitution, game: game, player_out: players_out.last, player_in: players_in.last) }
      before do
        (0..max_substitutions-1).each { |n| create(:substitution, game: game, player_in: players_in[n], player_out: players_out[n]) }
      end
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:game) }
      it { substitution.error_on(:game).should include I18n.t(cant_have_more_substitutions_error_translation_key) }

      context "and another in the away team" do
        let(:player_in) { create(:player_with_club, player_club: game.club_away) }
        let(:player_out) { create(:player_in_game_away, player_game: game) }
        let(:substitution) { create(:substitution, game: game, player_out: player_out, player_in: player_in) }
        subject { substitution }

        it { should be_valid }
      end
  end
  end
end
