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

  context "with points less than -99" do
    let(:player_stat) { build(:player_stat, points: -100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => -99) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with points greater than 99" do
    let(:player_stat) { build(:player_stat, points: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer points" do
    let(:player_stat) { build(:player_stat, points: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:points) }
    it { player_stat.error_on(:points).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without goals scored" do
    let(:player_stat) { build(:player_stat, goals_scored: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:goals_scored) }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with goals scored less than 0" do
    let(:player_stat) { build(:player_stat, goals_scored: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:goals_scored) }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with goals scored greater than 99" do
    let(:player_stat) { build(:player_stat, goals_scored: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:goals_scored) }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer goals scored" do
    let(:player_stat) { build(:player_stat, goals_scored: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:goals_scored) }
    it { player_stat.error_on(:goals_scored).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without assists" do
    let(:player_stat) { build(:player_stat, assists: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:assists) }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with assists less than 0" do
    let(:player_stat) { build(:player_stat, assists: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:assists) }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with assists greater than 99" do
    let(:player_stat) { build(:player_stat, assists: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:assists) }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer assists" do
    let(:player_stat) { build(:player_stat, assists: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:assists) }
    it { player_stat.error_on(:assists).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without yellow cards" do
    let(:player_stat) { build(:player_stat, yellow_cards: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:yellow_cards) }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with yellow cards less than 0" do
    let(:player_stat) { build(:player_stat, yellow_cards: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:yellow_cards) }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with yellow cards greater than 99" do
    let(:player_stat) { build(:player_stat, yellow_cards: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:yellow_cards) }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer yellow cards" do
    let(:player_stat) { build(:player_stat, yellow_cards: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:yellow_cards) }
    it { player_stat.error_on(:yellow_cards).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without red cards" do
    let(:player_stat) { build(:player_stat, red_cards: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:red_cards) }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with red cards less than 0" do
    let(:player_stat) { build(:player_stat, red_cards: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:red_cards) }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with red cards greater than 99" do
    let(:player_stat) { build(:player_stat, red_cards: 100) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:red_cards) }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 99) }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.too_long', count: 2) }
  end

  context "with not integer red cards" do
    let(:player_stat) { build(:player_stat, red_cards: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:red_cards) }
    it { player_stat.error_on(:red_cards).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without lineups" do
    let(:player_stat) { build(:player_stat, lineups: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:lineups) }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.wrong_length', count: 1) }
  end

  context "with lineups less than 0" do
    let(:player_stat) { build(:player_stat, lineups: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:lineups) }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.wrong_length', count: 1) }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with lineups greater than 1" do
    let(:player_stat) { build(:player_stat, lineups: 2) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:lineups) }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 1) }
  end

  context "with not integer lineups" do
    let(:player_stat) { build(:player_stat, lineups: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:lineups) }
    it { player_stat.error_on(:lineups).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without games played" do
    let(:player_stat) { build(:player_stat, games_played: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:games_played) }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.wrong_length', count: 1) }
  end

  context "with games played less than 0" do
    let(:player_stat) { build(:player_stat, games_played: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(2).error_on(:games_played) }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.wrong_length', count: 1) }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with games played greater than 1" do
    let(:player_stat) { build(:player_stat, games_played: 2) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:games_played) }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 1) }
  end

  context "with not integer games played" do
    let(:player_stat) { build(:player_stat, games_played: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:games_played) }
    it { player_stat.error_on(:games_played).should include I18n.t('errors.messages.not_an_integer') }
  end

  context "without minutes played" do
    let(:player_stat) { build(:player_stat, minutes_played: nil) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(3).error_on(:minutes_played) }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.blank') }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.not_a_number') }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.too_short', count: 1) }
  end

  context "with minutes played less than 0" do
    let(:player_stat) { build(:player_stat, minutes_played: -1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:minutes_played) }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
  end

  context "with minutes played greater than 130" do
    let(:player_stat) { build(:player_stat, minutes_played: 131) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:minutes_played) }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
  end

  context "with not integer minutes played" do
    let(:player_stat) { build(:player_stat, minutes_played: 0.1) }
    subject { player_stat }

    it { should_not be_valid }
    it { should have(1).error_on(:minutes_played) }
    it { player_stat.error_on(:minutes_played).should include I18n.t('errors.messages.not_an_integer') }
  end
end
