require 'spec_helper'

describe Extensions::GameEvent do
  describe "with default player relation" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.player.should_play_in_any_club' }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :player_id

        include Extensions::GameEvent
        acts_as_game_event
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { player: { should_play_in_any_club: 'Error message'} } } } }
      }
    end

    describe "when exted a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_with_club, player_club: game.club_home) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, player: player) }
        subject { dummy }

        it { should be_valid }
        it { should_not respond_to(:second_player_file) }
        it { should_not respond_to(:same_player?) }
        it { should_not respond_to(:same_club?) }
        it { should_not respond_to(:validate_player_in_clubs) }
      end

      context "without game" do
        let(:dummy) { DummyModel.new(player: player) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:game) }
        it { dummy.error_on(:game).should include I18n.t('errors.messages.blank') }
      end

      context "without player" do
        let(:dummy) { DummyModel.new(game: game) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t('errors.messages.blank') }
        it { dummy.error_on(:player).should include I18n.t(error_translation_key) }
      end

      context "with a player who does not play in the game" do
        let(:player_not_play) { create(:player) }
        let(:dummy) { DummyModel.new(game: game, player: player_not_play) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(error_translation_key) }
      end
    end
  end

  describe "without default player relation" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.scorer.should_play_in_any_club' }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :scorer_id

        include Extensions::GameEvent
        acts_as_game_event player_relation: :scorer
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { scorer: { should_play_in_any_club: 'Error message'} } } } }
      }
    end

    describe "when exted a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_with_club, player_club: game.club_home) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, scorer: player) }
        subject { dummy }

        it { should be_valid }
      end

      context "without game" do
        let(:dummy) { DummyModel.new(scorer: player) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:game) }
        it { dummy.error_on(:game).should include I18n.t('errors.messages.blank') }
      end

      context "without player" do
        let(:dummy) { DummyModel.new(game: game) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:scorer) }
        it { dummy.error_on(:scorer).should include I18n.t('errors.messages.blank') }
        it { dummy.error_on(:scorer).should include I18n.t(error_translation_key) }
      end

      context "with a player who does not play in the game" do
        let(:player_not_play) { create(:player) }
        let(:dummy) { DummyModel.new(game: game, scorer: player_not_play) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:scorer) }
        it { dummy.error_on(:scorer).should include I18n.t(error_translation_key) }
      end
    end
  end

  describe "without second player relation" do
    let(:same_club_error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.second_player.should_be_in_same_club' }
    let(:different_player_error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.second_player.should_be_diferent' }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :player_id
        integer :second_player_id

        include Extensions::GameEvent
        acts_as_game_event second_player_relation: :second_player
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { second_player: { should_be_in_same_club: 'Same club error message' } } } } }
      }
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { second_player: { should_be_diferent: 'Different player error message' } } } } }
      }
    end

    describe "when exted a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_with_club, player_club: game.club_home) }
      let(:second_player) { create(:player_with_club, player_club: game.club_home) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: second_player) }
        subject { dummy }

        it { should be_valid }
        it { should respond_to(:second_player_file) }
        it { should respond_to(:same_player?) }
        it { should respond_to(:same_club?) }
        it { should respond_to(:validate_player_in_clubs) }
      end

      context "with a second player who does not play in the same club than player" do
        let(:second_player_different_club) { create(:player_with_club, player_club: game.club_away) }
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: second_player_different_club) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:second_player) }
        it { dummy.error_on(:second_player).should include I18n.t(same_club_error_translation_key) }
      end

      context "with a player as second player" do
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: player) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:second_player) }
        it { dummy.error_on(:second_player).should include I18n.t(different_player_error_translation_key) }
      end
    end
  end
end