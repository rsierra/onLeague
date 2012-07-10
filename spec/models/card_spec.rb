require 'spec_helper'

describe Card do
  let(:error_translation_key) { 'activerecord.errors.models.card.attributes.kind' }
  let(:only_one_kind_error_translation_key) { "#{error_translation_key}.should_only_one_kind" }
  let(:not_exist_any_red_error_translation_key) { "#{error_translation_key}.should_not_exist_any_red_before" }
  let(:exists_yellow_error_translation_key) { "#{error_translation_key}.should_exists_yellow_before" }

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

      context "and change kind to red" do
        let(:new_kind) { Card.kind.values.second }
        before { card.kind = new_kind }
        subject { card }

        it { should_not be_valid }
        it { should have(1).error_on(:kind) }
        it { card.error_on(:kind).should include I18n.t(exists_yellow_error_translation_key) }
      end

      context "and change kind to direct red" do
        let(:new_kind) { Card.kind.values.last }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { last_player_stat; card.update_attributes(kind: new_kind) }
        subject { new_player_stat }

        its(:minutes_played) { should eql card.minute }
        its(:minutes_played) { should eql last_player_stat.minutes_played + card.card_stats[:minutes_played] }
        its(:points) { should eql -1 }
        its(:points) { should eql last_player_stat.points - Card::STATS_YELLOW[:points] + Card::STATS_DIRECT_RED[:points] }
        its(:yellow_cards) { should eql 0 }
        its(:yellow_cards) { should eql last_player_stat.yellow_cards - Card::STATS_YELLOW[:yellow_cards] }
        its(:red_cards) { should eql 1 }
        its(:red_cards) { should eql last_player_stat.red_cards + Card::STATS_DIRECT_RED[:red_cards] }
      end

      context "and change minute" do
        let(:new_minute) { 10 }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { last_player_stat; card.update_attributes(minute: new_minute) }
        subject { new_player_stat }

        it { should eql last_player_stat }
      end

      context "and change player" do
        let(:last_player) { card.player }
        let(:new_player) { create(:player_in_game, player_game: card.game) }

        before { last_player; card.update_attributes(player: new_player) }

        context "the plast player stats" do
          let(:last_player_stat) { last_player.stats.season(card.game.season).week(card.game.week).first }
          subject { last_player_stat }

          its(:points) { should eql 2 }
          its(:points) { should eql Lineup::STATS[:points] }
          its(:yellow_cards) { should be_zero }
          its(:red_cards) { should be_zero }
        end

        context "the new player stats" do
          let(:new_player_stat) { new_player.stats.season(card.game.season).week(card.game.week).first }
          subject { new_player_stat }

          its(:points) { should eql Lineup::STATS[:points] + card.card_stats[:points] }
          its(:yellow_cards) { should eql Card::STATS_YELLOW[:yellow_cards] }
          its(:red_cards) { should be_zero }
        end
      end

      context "and destroy" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { player_stat; card.destroy }
        subject { player_stat.reload }

        its(:points) { should eql 2 }
        its(:points) { should eql Lineup::STATS[:points] }
        its(:yellow_cards) { should be_zero }
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

      context "and change kind to yellow" do
        let(:new_kind) { Card.kind.values.first }
        before { card.kind = new_kind }
        subject { card }

        it { should_not be_valid }
        it { should have(1).error_on(:kind) }
        it { card.error_on(:kind).should include I18n.t(only_one_kind_error_translation_key) }
      end

      context "and change kind to direct red" do
        let(:new_kind) { Card.kind.values.last }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { card; last_player_stat; card.update_attributes(kind: new_kind) }
        subject { new_player_stat }

        its(:minutes_played) { should eql card.minute }
        its(:minutes_played) { should eql last_player_stat.minutes_played }
        its(:points) { should eql -2 }
        its(:points) { should eql last_player_stat.points - Card::STATS_RED[:points] + Card::STATS_DIRECT_RED[:points] }
        its(:yellow_cards) { should eql 1 }
        its(:yellow_cards) { should eql last_player_stat.yellow_cards - Card::STATS_RED[:yellow_cards] }
        its(:red_cards) { should eql 1 }
        its(:red_cards) { should eql last_player_stat.red_cards }
      end

      context "and change minute" do
        let(:new_minute) { 10 }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { last_player_stat; card.update_attributes(minute: new_minute) }
        subject { new_player_stat }

        its(:points) { should eql last_player_stat.points }
        its(:red_cards) { should eql last_player_stat.red_cards }
        its(:yellow_cards) { should eql last_player_stat.yellow_cards }
        its(:minutes_played) { should_not eql last_player_stat.minutes_played }
        its(:minutes_played) { should eql card.minute }
      end

      context "and change player" do
        let(:last_player) { card.player }
        let(:new_player) { create(:player_in_game, player_game: card.game) }

        before do
          create(:card, game: card.game, player: new_player)
          last_player; card.update_attributes(player: new_player)
        end

        context "the plast player stats" do
          let(:last_player_stat) { last_player.stats.season(card.game.season).week(card.game.week).first }
          subject { last_player_stat }

          its(:points) { should eql 1 }
          its(:points) { should eql Lineup::STATS[:points] + Card::STATS_YELLOW[:points] }
          its(:yellow_cards) { should eql 1 }
          its(:red_cards) { should be_zero }
        end

        context "the new player stats" do
          let(:new_player_stat) { new_player.stats.season(card.game.season).week(card.game.week).first }
          subject { new_player_stat }

          its(:points) { should eql 0 }
          its(:points) { should eql Lineup::STATS[:points] + Card::STATS_YELLOW[:points] + Card::STATS_RED[:points] }
          its(:yellow_cards) { should eql 2 }
          its(:red_cards) { should eql 1 }
        end
      end

      context "and destroy" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { player_stat; card.destroy }
        subject { player_stat.reload }

        its(:points) { should eql 1 }
        its(:points) { should eql Lineup::STATS[:points] + Card::STATS_YELLOW[:points]}
        its(:yellow_cards) { should eql 1 }
        its(:red_cards) { should be_zero }
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

      context "and change kind to yellow" do
        let(:new_kind) { Card.kind.values.first }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { card; last_player_stat; card.update_attributes(kind: new_kind) }
        subject { new_player_stat }

        its(:minutes_played) { should eql Player::MAX_MINUTES }
        its(:points) { should eql 1 }
        its(:points) { should eql last_player_stat.points - Card::STATS_DIRECT_RED[:points] + Card::STATS_YELLOW[:points] }
        its(:yellow_cards) { should eql 1 }
        its(:red_cards) { should be_zero }
      end

      context "and change kind to red" do
        let(:yellow_card) { create(:card) }
        let(:card) { create(:card, :direct_red, game: yellow_card.game, player: yellow_card.player) }
        let(:new_kind) { Card.kind.values.second }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }

        before { last_player_stat; card.update_attributes(kind: new_kind) }
        subject { new_player_stat }

        its(:minutes_played) { should eql card.minute }
        its(:minutes_played) { should eql last_player_stat.minutes_played }
        its(:points) { should eql 0 }
        its(:points) { should eql last_player_stat.points - Card::STATS_DIRECT_RED[:points] + Card::STATS_RED[:points] }
        its(:yellow_cards) { should eql 2 }
        its(:red_cards) { should eql 1 }
      end

      context "and change minute" do
        let(:new_minute) { 10 }
        let(:new_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        let(:last_player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { last_player_stat; card.update_attributes(minute: new_minute) }
        subject { new_player_stat }

        its(:points) { should eql last_player_stat.points }
        its(:red_cards) { should eql last_player_stat.red_cards }
        its(:yellow_cards) { should eql last_player_stat.yellow_cards }
        its(:minutes_played) { should_not eql last_player_stat.minutes_played }
        its(:minutes_played) { should eql card.minute }
      end

      context "and change player" do
        let(:last_player) { card.player }
        let(:new_player) { create(:player_in_game, player_game: card.game) }

        before { last_player; card.update_attributes(player: new_player) }

        context "the plast player stats" do
          let(:last_player_stat) { last_player.stats.season(card.game.season).week(card.game.week).first }
          subject { last_player_stat }

          its(:points) { should eql 2 }
          its(:points) { should eql Lineup::STATS[:points] }
          its(:yellow_cards) { should be_zero }
          its(:red_cards) { should be_zero }
        end

        context "the new player stats" do
          let(:new_player_stat) { new_player.stats.season(card.game.season).week(card.game.week).first }
          subject { new_player_stat }

          its(:points) { should eql -1 }
          its(:points) { should eql Lineup::STATS[:points] + Card::STATS_DIRECT_RED[:points] }
          its(:yellow_cards) { should be_zero }
          its(:red_cards) { should eql 1 }
        end
      end

      context "and destroy" do
        let(:player_stat) { card.player.stats.season(card.game.season).week(card.game.week).first }
        before { player_stat; card.destroy }
        subject { player_stat.reload }

        its(:points) { should eql 2 }
        its(:points) { should eql Lineup::STATS[:points] }
        its(:yellow_cards) { should be_zero }
        its(:red_cards) { should be_zero }
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
