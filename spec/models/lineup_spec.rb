require 'spec_helper'

describe Lineup do
  describe "when create" do
    let(:error_translation_key) { 'activerecord.errors.models.lineup.attributes' }
    let(:play_in_any_club_error_translation_key) { "#{error_translation_key}.player.should_play_in_any_club" }
    let(:cant_have_more_lineups_error_translation_key) { "#{error_translation_key}.game.cant_have_more" }

    context "with correct data" do
      let(:lineup) { create(:lineup) }
      subject { lineup }

      it { should be_valid }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { lineup.player.stats.season(lineup.game.season).week(lineup.game.week).first }
        subject { player_stat }

        its(:points) { should eql 2 }
        its(:points) { should eql Lineup::STATS[:points] }
        its(:lineups) { should eql 1 }
        its(:lineups) { should eql Lineup::STATS[:lineups] }
        its(:games_played) { should eql 1 }
        its(:games_played) { should eql Lineup::STATS[:games_played] }
        its(:minutes_played) { should eql 90 }
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
      it { should have(1).error_on(:game) }
      it { lineup.error_on(:game).should include I18n.t('errors.messages.blank') }
    end

    context "without player" do
      let(:lineup) { build(:lineup, player: nil) }
      subject { lineup }

      it { should_not be_valid }
      it { should have(2).error_on(:player) }
      it { lineup.error_on(:player).should include I18n.t('errors.messages.blank') }
      it { lineup.error_on(:player).should include I18n.t(play_in_any_club_error_translation_key) }
    end

    context "with a player who does not play in the game" do
      let(:player_not_play) { create(:player_with_club) }
      let(:lineup) { build(:lineup, player: player_not_play) }
      subject { lineup }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { lineup.error_on(:player).should include I18n.t(play_in_any_club_error_translation_key) }
    end

    context "more than max lineups for a game" do
      let(:game) { create(:game) }
      let(:players) { create_list(:player_in_game, Lineup.max_per_game, player_game: game) }
      let(:player) { create(:player_with_club, player_club: game.club_home) }
      let(:lineup) { build(:lineup, game: game, player: player) }
      before { players }
      subject { lineup }

      it { should_not be_valid }
      it { should have(1).error_on(:game) }
      it { lineup.error_on(:game).should include I18n.t(cant_have_more_lineups_error_translation_key) }

      context "and another in the away team" do
        let(:player) { create(:player_with_club, player_club: game.club_away) }
        let(:lineup) { create(:lineup, game: game, player: player) }
        subject { lineup }

        it { should be_valid }
      end
    end
  end

  context "when get lineups of a group of playes" do
    let(:game) { create(:game) }
    let(:first_player) { create(:player_in_game, player_game: game)}
    let(:first_lineup) { first_player.lineups.first }
    let(:second_player) { create(:player_in_game, player_game: game)}
    let(:second_lineup) { second_player.lineups.first }
    let(:third_player) { create(:player_in_game, player_game: game)}
    let(:third_lineup) { third_player.lineups.first }

    before { first_lineup; second_lineup; third_lineup }

    it { Lineup.of_players.should == [] }
    it { Lineup.of_players([]).should == [] }
    it { Lineup.of_players(first_player.id).should == [first_lineup] }
    it { Lineup.of_players(third_player.id).should == [third_lineup] }
    it { Lineup.of_players([first_player.id, second_player.id]).should == [first_lineup, second_lineup] }
    it { Lineup.of_players([first_player.id, third_player.id]).should == [first_lineup, third_lineup] }
  end

  describe "when get #count_another_in_game" do
    context "before create the first lineup" do
      let(:lineup) { build(:lineup) }
      subject { lineup }

      its(:count_another_in_game) { should eql 0 }
    end

    context "after create the first lineup" do
      let(:lineup) { create(:lineup) }
      subject { lineup }

      its(:count_another_in_game) { should eql 0 }
    end

    context "with max lineups" do
      let(:number_of_lineups) { Lineup.max_per_game }
      let(:game) { create(:game) }
      let(:players) { create_list(:player_in_game, number_of_lineups, player_game: game) }
      let(:last_lineup) { game.lineups.last }
      let(:player) { create(:player_with_club, player_club: game.club_home) }
      let(:new_lineup) { build(:lineup, game: game, player: player) }
      before { players }

      it { last_lineup.count_another_in_game.should eql number_of_lineups-1 }
      it { new_lineup.count_another_in_game.should eql number_of_lineups }
    end
  end
end
