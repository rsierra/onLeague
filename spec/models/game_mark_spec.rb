require 'spec_helper'

describe GameMark do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.game_mark.attributes' }
    let(:play_in_any_club_error_translation_key) { "#{error_translation_key}.player.should_play_in_any_club" }

    context "with correct data" do
      let(:game_mark) { create(:game_mark) }
      subject { game_mark }

      it { should be_valid }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { game_mark.player.stats.season(game_mark.game.season).week(game_mark.game.week).first }
        subject { player_stat }

        its(:points) { should eq 1 }
        its(:points) { should eq game_mark.mark }
      end

      context "and update player" do
        let(:player) { create(:player_with_club, player_club: player_was.club) }
        let(:player_was) { game_mark.player }
        before { game_mark; player_was; game_mark.update_attributes(player: player) }

        context "the was player" do
          let(:player_was_stats) { player_was.stats.season(game_mark.game.season).week(game_mark.game.week).first }
          subject { player_was_stats }

          its(:points) { should be_zero }
        end

        context "the new player" do
          let(:player_stats) { player.stats.season(game_mark.game.season).week(game_mark.game.week).first }
          subject { player_stats }

          its(:points) { should eq 1 }
          its(:points) { should eq game_mark.mark }
        end
      end

      describe "and change mark" do
        let(:new_mark) { 2 }
        let(:player_stat) { game_mark.player.stats.season(game_mark.game.season).week(game_mark.game.week).first }
        before { game_mark.update_attributes(mark: new_mark) }
        subject { player_stat }

        its(:points) { should eq new_mark }
      end

      context "and then destroy" do
        let(:player) { game_mark.player }
        before {  player; game_mark.destroy }
        subject { player.stats.season(game_mark.game.season).week(game_mark.game.week).first }

        its(:points) { should be_zero }
      end

      context "and create another with same player" do
        let(:another_game_mark) { build(:game_mark, game: game_mark.game, player: game_mark.player) }
        subject { another_game_mark }

        it { should_not be_valid }
        it { should have(1).error_on(:player_id) }
        it { another_game_mark.error_on(:player_id).should include I18n.t('errors.messages.taken') }
      end
    end

    context "without game" do
      let(:game_mark) { build(:game_mark) }
      before { game_mark.game = nil }
      subject { game_mark }

      it { should_not be_valid }
      it { should have(1).error_on(:game) }
      it { game_mark.error_on(:game).should include I18n.t('errors.messages.blank') }
    end

    context "without player" do
      let(:game_mark) { build(:game_mark, player: nil) }
      subject { game_mark }

      it { should_not be_valid }
      it { should have(2).error_on(:player) }
      it { game_mark.error_on(:player).should include I18n.t('errors.messages.blank') }
      it { game_mark.error_on(:player).should include I18n.t(play_in_any_club_error_translation_key) }
    end

    context "with a player who does not play in the game" do
      let(:player_not_play) { create(:player_with_club) }
      let(:game_mark) { build(:game_mark, player: player_not_play) }
      subject { game_mark }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { game_mark.error_on(:player).should include I18n.t(play_in_any_club_error_translation_key) }
    end
  end
end
