require 'spec_helper'

describe Extensions::GameEvent do
  describe "with default player relation" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.player' }
    let(:any_club_error_translation_key) { "#{error_translation_key}.should_play_in_any_club" }
    let(:playing_error_translation_key) { "#{error_translation_key}.should_be_playing" }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :player_id
        integer :minute, default: 1

        include Extensions::GameEvent
        acts_as_game_event
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { player: { should_play_in_any_club: 'Play in any club error message'} } } } }
      }

      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { player: { should_be_playing: 'Playing error message'} } } } }
      }
    end

    describe "when extend a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_in_game, player_game: game) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, player: player) }
        subject { dummy }

        it { should be_valid }
        it { should respond_to(:event_player) }
        it { should respond_to(:player_file) }
        it { should_not respond_to(:second_player_file) }
        it { should_not respond_to(:same_player?) }
        it { should_not respond_to(:same_club?) }
        it { should_not respond_to(:validate_player_in_clubs) }

        its(:event_player) { should eq player }
        its(:player_file) { should eq game.club_home.club_files.on(game.date).of(player).last }

        context "when get elements of a player" do
          let(:another_player) { create(:player_in_game, player_game: game) }
          let(:second_dummy) { DummyModel.create(game: game, player: player) }
          let(:another_dummy) { DummyModel.create(game: game, player: another_player) }

          before { dummy.save; second_dummy; another_dummy }

          it { DummyModel.of(player).should eq [dummy, second_dummy] }
          it { DummyModel.of(another_player).should eq [another_dummy] }
        end

        context "when get elements before a minute" do
          let(:second_dummy) { DummyModel.create(game: game, player: player, minute: 50) }
          let(:third_dummy) { DummyModel.create(game: game, player: player, minute: 100) }

          before { dummy.save; second_dummy; third_dummy }

          it { DummyModel.before(25).should eq [dummy] }
          it { DummyModel.before(50).should eq [dummy] }
          it { DummyModel.before(75).should eq [dummy, second_dummy] }
          it { DummyModel.before(100).should eq [dummy, second_dummy] }
          it { DummyModel.before(110).should eq [dummy, second_dummy, third_dummy] }
        end
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
        it { dummy.error_on(:player).should include I18n.t(any_club_error_translation_key) }
      end

      context "with a player who does not play in the game" do
        let(:player_not_play) { create(:player) }
        let(:dummy) { DummyModel.new(game: game, player: player_not_play) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(any_club_error_translation_key) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end

      context "without minute" do
        let(:dummy) { DummyModel.new(game: game, player: player, minute: nil) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:minute) }
        it { dummy.error_on(:minute).should include I18n.t('errors.messages.blank') }
        it { dummy.error_on(:minute).should include I18n.t('errors.messages.not_a_number') }
      end

      context "with minute less than 0" do
        let(:dummy) { DummyModel.new(game: game, player: player, minute: -1) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:minute) }
        it { dummy.error_on(:minute).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
      end

      context "with minute greater than 130" do
        let(:dummy) { DummyModel.new(game: game, player: player, minute: 131) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:minute) }
        it { dummy.error_on(:minute).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
      end

      context "with not integer minute" do
        let(:dummy) { DummyModel.new(game: game, player: player, minute: 10.1) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:minute) }
        it { dummy.error_on(:minute).should include I18n.t('errors.messages.not_an_integer') }
      end
    end
  end

  describe "without default player relation" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.scorer' }
    let(:any_club_error_translation_key) { "#{error_translation_key}.should_play_in_any_club" }
    let(:playing_error_translation_key) { "#{error_translation_key}.should_be_playing" }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :scorer_id
        integer :minute, default: 1

        include Extensions::GameEvent
        acts_as_game_event player_relation: :scorer
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { scorer: { should_play_in_any_club: 'Play in any club error message'} } } } }
      }

      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { scorer: { should_be_playing: 'Playing error message'} } } } }
      }
    end

    describe "when extend a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_in_game, player_game: game) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, scorer: player) }
        subject { dummy }

        it { should be_valid }
        it { should respond_to(:event_player) }
        it { should respond_to(:player_file) }
        it { should_not respond_to(:second_player_file) }
        it { should_not respond_to(:same_player?) }
        it { should_not respond_to(:same_club?) }
        it { should_not respond_to(:validate_player_in_clubs) }

        its(:event_player) { should eq player }
        its(:player_file) { should eq game.club_home.club_files.on(game.date).of(player).last }
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
        it { dummy.error_on(:scorer).should include I18n.t(any_club_error_translation_key) }
      end

      context "with a player who does not play in the game" do
        let(:player_not_play) { create(:player) }
        let(:dummy) { DummyModel.new(game: game, scorer: player_not_play) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:scorer) }
        it { dummy.error_on(:scorer).should include I18n.t(any_club_error_translation_key) }
        it { dummy.error_on(:scorer).should include I18n.t(playing_error_translation_key) }
      end
    end
  end

  describe "with second player relation" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.second_player' }
    let(:not_play_error_translation_key) { "#{error_translation_key}.should_play_in_any_club" }
    let(:same_club_error_translation_key) { "#{error_translation_key}.should_be_in_same_club" }
    let(:different_player_error_translation_key) { "#{error_translation_key}.should_be_diferent" }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :player_id
        integer :second_player_id
        integer :minute, default: 1

        include Extensions::GameEvent
        acts_as_game_event second_player_relation: :second_player
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { second_player: { should_play_in_any_club: 'Not play error message' } } } } }
      }
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { second_player: { should_be_in_same_club: 'Same club error message' } } } } }
      }
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { second_player: { should_be_diferent: 'Different player error message' } } } } }
      }
    end

    describe "when extend a model" do
      let(:game) { create(:game) }
      let(:player) { create(:player_in_game, player_game: game) }
      let(:second_player) { create(:player_in_game, player_game: game) }

      context "with correct data" do
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: second_player) }
        subject { dummy }

        it { should be_valid }
        it { should respond_to(:event_player) }
        it { should respond_to(:player_file) }
        it { should respond_to(:event_second_player) }
        it { should respond_to(:second_player_file) }
        it { should respond_to(:same_player?) }
        it { should respond_to(:same_club?) }
        it { should respond_to(:validate_player_in_clubs) }

        its(:event_player) { should eq player }
        its(:player_file) { should eq game.club_home.club_files.on(game.date).of(player).last }
        its(:event_second_player) { should eq second_player }
        its(:second_player_file) { should eq game.club_home.club_files.on(game.date).of(second_player).last }
        its(:same_player?) { should be_false }
        its(:same_club?) { should be_true }

        context "when get elements for a player" do
          let(:another_player) { create(:player_in_game, player_game: game) }
          let(:second_dummy) { DummyModel.create(game: game, player: player, second_player: second_player) }
          let(:another_dummy) { DummyModel.create(game: game, player: player, second_player: another_player) }

          before { dummy.save; second_dummy; another_dummy }

          it { DummyModel.for(second_player).should eq [dummy, second_dummy] }
          it { DummyModel.for(another_player).should eq [another_dummy] }
          it { DummyModel.for(player).should be_empty }
        end
      end

      context "with a second player who does not play in the game" do
        let(:player_not_play) { create(:player) }
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: player_not_play) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(2).error_on(:second_player) }
        it { dummy.error_on(:second_player).should include I18n.t(not_play_error_translation_key) }
        it { dummy.error_on(:second_player).should include I18n.t(same_club_error_translation_key) }
      end

      context "with a second player who does not play in the same club than player" do
        let(:second_player_different_club) { create(:player_with_club, player_club: game.club_away) }
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: second_player_different_club) }
        subject { dummy }

        it { should_not be_valid }
        its(:same_club?) { should be_false }
        it { should have(1).error_on(:second_player) }
        it { dummy.error_on(:second_player).should include I18n.t(same_club_error_translation_key) }
      end

      context "with a player as second player" do
        let(:dummy) { DummyModel.new(game: game, player: player, second_player: player) }
        subject { dummy }

        it { should_not be_valid }
        its(:same_player?) { should be_true }
        it { should have(1).error_on(:second_player) }
        it { dummy.error_on(:second_player).should include I18n.t(different_player_error_translation_key) }
      end
    end
  end
end
