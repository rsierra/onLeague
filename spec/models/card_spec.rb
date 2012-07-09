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
      let(:card) { create(:card, :red) }
      subject { card }

      it { should be_valid }
      it { card.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        subject { player_stat }

        its(:points) { should be_zero }
        its(:red_cards) { should eql 1 }
        its(:yellow_cards) { should eql 2 }
        its(:minutes_played) { should eql card.minute }
      end
    end

    context "a direct red card with correct data" do
      let(:card) { create(:card, :direct_red) }
      subject { card }

      it { should be_valid }
      it { card.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player }
      its(:player) { should have(1).stats }

      context "the player stats" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        subject { player_stat }

        its(:points) { should eql Lineup::STATS[:points] + card.card_stats[:points] }
        its(:red_cards) { should eql 1 }
        its(:yellow_cards) { should be_zero }
        its(:minutes_played) { should eql card.minute }
      end

      context "a direct red card to a player substituted" do
        let(:minute_in) { 60 }
        let(:minute_red) { 70 }
        let(:substitution) { create(:substitution, minute: minute_in) }
        let(:card) { create(:card, :direct_red, game: substitution.game, player: substitution.player_in, minute: minute_red) }
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        subject { player_stat }

        its(:points) { should eql Substitution::STATS_IN[:points] + card.card_stats[:points] }
        its(:red_cards) { should eql 1 }
        its(:yellow_cards) { should be_zero }
        its(:minutes_played) { should eql minute_red - minute_in }
      end

      describe "a duplicated" do
        let(:error_translation_key) { 'activerecord.errors.models.card.attributes.kind' }
        let(:only_one_kind_error_translation_key) { "#{error_translation_key}.should_only_one_kind" }
        let(:not_exist_any_red_error_translation_key) { "#{error_translation_key}.should_not_exist_any_red_before" }
        let(:exists_yellow_error_translation_key) { "#{error_translation_key}.should_exists_yellow_before" }

        context "yellow card with red card" do
          let(:red_card) { create(:card, :red) }
          let(:card) { build(:card, game: red_card.game, player: red_card.player) }
          subject { card }

          it { should_not be_valid }
          it { should have(2).error_on(:kind) }
          it { card.error_on(:kind).should include I18n.t(only_one_kind_error_translation_key) }
          it { card.error_on(:kind).should include I18n.t(not_exist_any_red_error_translation_key) }
        end

        context "yellow card with direct red card" do
          let(:direct_red_card) { create(:card, :direct_red) }
          let(:card) { build(:card, game: direct_red_card.game, player: direct_red_card.player) }
          subject { card }

          it { should_not be_valid }
          it { should have(1).error_on(:kind) }
          it { card.error_on(:kind).should include I18n.t(not_exist_any_red_error_translation_key) }
        end

        context "direct red card with red card" do
          let(:red_card) { create(:card, :red) }
          let(:card) { build(:card, :direct_red, game: red_card.game, player: red_card.player) }
          subject { card }

          it { should_not be_valid }
          it { should have(1).error_on(:kind) }
          it { card.error_on(:kind).should include I18n.t(not_exist_any_red_error_translation_key) }
        end

        context "red card with direct card" do
          let(:yellow_card) { create(:card) }
          let(:direct_red_card) { create(:card, :direct_red, game: yellow_card.game, player: yellow_card.player) }
          let(:card) { build(:card, kind: 'red', game: yellow_card.game, player: yellow_card.player) }
          before { yellow_card; direct_red_card; card }
          subject { card }

          it { should_not be_valid }
          it { should have(1).error_on(:kind) }
          it { card.error_on(:kind).should include I18n.t(not_exist_any_red_error_translation_key) }
        end

        context "red card without yellow card" do
          let(:card) { build(:card, kind: 'red') }
          subject { card }

          it { should_not be_valid }
          it { should have(1).error_on(:kind) }
          it { card.error_on(:kind).should include I18n.t(exists_yellow_error_translation_key) }
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
    let(:red_card) { create(:card, :red) }

    before { card; red_card }

    it { Card.red.should == [red_card] }
  end

  context "when get cards in a game" do
    let(:card) { create(:card) }
    let(:red_card) { create(:card, :red) }
    let(:direct_red_card) { create(:card, :direct_red) }

    before { card; red_card; direct_red_card }

    it { Card.in_game(card.game).should == [card] }
    it { Card.red.in_game(red_card.game).should == [red_card] }
    it { Card.in_game(direct_red_card.game).should == [direct_red_card] }
  end
end
