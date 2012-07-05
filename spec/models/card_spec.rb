require 'spec_helper'

describe Card do
  describe "when create" do
    context "a yellow card with correct data" do
      let(:card) { create(:card) }
      subject { card }

      it { should be_valid }
      it { card.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        subject { player_stat }

        its(:points) { should eql Lineup::STATS[:points] + card.card_stats[:points] }
        its(:yellow_cards) { should eql card.card_stats[:yellow_cards] }
        its(:red_cards) { should be_zero }
      end
    end

    context "a red card with correct data" do
      let(:card) { create(:red_card) }
      subject { card }

      it { should be_valid }
      it { card.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        subject { player_stat }

        its(:points) { should eql Lineup::STATS[:points] + card.card_stats[:points] }
        its(:red_cards) { should eql card.card_stats[:red_cards] }
        its(:yellow_cards) { should be_zero }
      end

      describe "and calculate points for stats" do
        context "without a yellow card" do
          subject { card }

          its(:red_card_points) { should eql -3 }
        end

        context "with a yellow card" do
          let(:yellow_card) { create(:card, game: card.game, player: card.player) }
          before { yellow_card; card }
          subject { card }

          its(:red_card_points) { should eql -2 }
        end

        context "with two yellow cards" do
          let(:yellow_card) { create(:card, game: card.game, player: card.player) }
          let(:second_yellow_card) { create(:card, game: card.game, player: card.player) }
          before { yellow_card; second_yellow_card; card }
          subject { card }

          its(:red_card_points) { should eql -1 }
        end
      end
    end

    context "without kind" do
      let(:card) { build(:card, kind: nil) }
      subject { card }

      it { should_not be_valid }
      it { should have(2).error_on(:kind) }
      it { card.error_on(:kind).should include I18n.t('errors.messages.blank') }
      it { card.error_on(:kind).should include I18n.t('errors.messages.inclusion') }
    end
  end

  context "when get red cards" do
    let(:card) { create(:card) }
    let(:red_card) { create(:red_card) }

    before { card; red_card }

    it { Card.red.should == [red_card] }
  end

  context "when get cards in a game" do
    let(:card) { create(:card) }
    let(:red_card) { create(:red_card) }

    before { card; red_card }

    it { Card.in_game(card.game).should == [card] }
    it { Card.in_game(red_card.game).should == [red_card] }
  end
end
