require 'spec_helper'

describe Goal do
  describe "when create" do
    context "with correct data" do
      let(:goal) { create(:goal) }
      subject { goal }

      it { should be_valid }
      it { goal.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :scorer }
      its(:second_player_relation) { should eql :assistant }
      its(:scorer) { should have(1).stats }

      context "the player stats" do
        let(:scorer_stat) { goal.scorer.stats.season(goal.game.season).week(goal.game.week).first }
        subject { scorer_stat }

        its(:points) { should eql 5 }
        its(:points) { should eql Lineup::STATS[:points] + goal.scorer_stats[:points] }
        its(:goals_scored) { should eql 1 }
        its(:goals_scored) { should eql goal.scorer_stats[:goals_scored] }
      end

      describe "and change kind" do
        let(:scorer_stat) { goal.scorer.stats.season(goal.game.season).week(goal.game.week).first }
        before { goal.update_attributes(kind: new_kind)}
        subject { scorer_stat }

        context "to own" do
          let(:new_kind) { 'own' }

          its(:points) { should be_zero }
          its(:points) { should eql Lineup::STATS[:points] + goal.scorer_stats[:points] }
          its(:goals_scored) { should be_zero }
        end

        context "to penalty" do
          let(:new_kind) { 'penalty' }

          its(:points) { should eql 4 }
          its(:points) { should eql Lineup::STATS[:points] + goal.scorer_stats[:points] }
          its(:goals_scored) { should eql 1 }
          its(:goals_scored) { should eql goal.scorer_stats[:goals_scored] }
        end

        context "to penalty_saved" do
          let(:new_kind) { 'penalty_saved' }

          its(:points) { should be_zero }
          its(:points) { should eql Lineup::STATS[:points] + goal.scorer_stats[:points] }
          its(:goals_scored) { should be_zero }
        end

        context "to penalty_out" do
          let(:new_kind) { 'penalty_out' }

          its(:points) { should eql -1 }
          its(:points) { should eql Lineup::STATS[:points] + goal.scorer_stats[:points] }
          its(:goals_scored) { should be_zero }
        end
      end

      context "and assistant" do
        let(:assistant) { create(:player_in_game, player_game: goal.game) }
        let(:assistant_stat) { goal.assistant.stats.season(goal.game.season).week(goal.game.week).first }
        before { goal.update_attributes(assistant: assistant) }
        subject { assistant_stat }

        its(:points) { should eql 3 }
        its(:points) { should eql Lineup::STATS[:points] + goal.assistant_stats[:points] }
        its(:assists) { should eql 1 }
        its(:assists) { should eql goal.assistant_stats[:assists] }

        context "and destroy" do
          before { assistant_stat; goal.destroy }
          subject { assistant_stat.reload }

          its(:points) { should eql 2 }
          its(:points) { should eql Lineup::STATS[:points] }
          its(:assists) { should be_zero }
        end
      end

      context "and destroy" do
        let(:scorer_stat) { goal.scorer.stats.season(goal.game.season).week(goal.game.week).first }
        before { scorer_stat; goal.destroy }
        subject { scorer_stat.reload }

        its(:points) { should eql 2 }
        its(:points) { should eql Lineup::STATS[:points] }
        its(:goals_scored) { should be_zero }
      end
    end

    context "without kind" do
      let(:goal) { build(:goal, kind: nil) }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:kind) }
      it { goal.error_on(:kind).should include I18n.t('errors.messages.blank') }
      it { goal.error_on(:kind).should include I18n.t('errors.messages.inclusion') }
    end

    context "without assistant and no regular" do
      let(:goal) { build(:goal, kind: Goal.kind.values.last) }
      subject { goal }

      it { should be_valid }
    end

    context "with assistant in a no regular" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_with_club, player_club: game.club_home) }
      let(:assistant) { create(:player_with_club, player_club: game.club_home) }
      let(:goal) { build(:goal, game: game, scorer: scorer, assistant: assistant, kind: Goal.kind.values.last) }
      subject { goal }

      it { should_not be_valid }
      it { should have(2).error_on(:assistant) }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_not_be') }
      it { goal.error_on(:assistant).should include I18n.t('activerecord.errors.models.goal.attributes.assistant.should_be_playing') }
    end
  end

  context "when get goals of a club" do
    let(:game) { create(:game) }
    let(:home_scorer) { create(:player_in_game, player_game: game) }
    let(:away_scorer) { create(:player_in_game_away, player_game: game) }
    let(:home_goal) { create(:goal, game: game, scorer: home_scorer) }
    let(:away_goal) { create(:goal, game: game, scorer: away_scorer) }

    before { home_goal; away_goal }

    it { Goal.club(game.club_home).should == [home_goal] }
    it { Goal.club(game.club_away).should == [away_goal] }
  end
end
