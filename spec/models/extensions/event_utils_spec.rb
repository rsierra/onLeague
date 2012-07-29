require 'spec_helper'

describe Extensions::EventUtils do
  describe "with no limit per game" do
    let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.game' }
    let(:have_more_error_translation_key) { "#{error_translation_key}.cant_have_more" }
    let(:active_error_translation_key) { "#{error_translation_key}.should_be_active" }
    before(:all) do
      build_model :dummy_models do
        integer :game_id
        integer :player_id

        include Extensions::EventUtils

        belongs_to :player
      end
      I18n.backend.store_translations I18n.locale, activerecord: {
        errors: { models: { dummy_model: { attributes: { player: { should_be_active: 'Game active error message'} } } } }
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
        it { should respond_to(:count_another_in_game) }

        its(:event_player) { should eql player }
        its(:player_file) { should eql game.club_home.club_files.on(game.date).of(player).last }

        context "when get elements of a player" do
          let(:another_player) { create(:player_in_game, player_game: game) }
          let(:second_dummy) { DummyModel.create(game: game, player: player) }
          let(:another_dummy) { DummyModel.create(game: game, player: another_player) }

          before { dummy.save; second_dummy; another_dummy }

          it { DummyModel.of(player).should == [dummy, second_dummy] }
          it { DummyModel.of(another_player).should == [another_dummy] }
        end
      end

      context "without game" do
        let(:dummy) { DummyModel.new(player: player) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:game) }
        it { dummy.error_on(:game).should include I18n.t('errors.messages.blank') }
      end

      context "with not active game" do
        let(:game) { create(:game, status: 'inactive') }
        let(:player) { create(:player_with_club, player_club: game.club_home) }
        let(:dummy) { DummyModel.new(game: game, player: player) }
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:game) }
        it { dummy.error_on(:game).should include I18n.t(active_error_translation_key) }
      end

      context "with max per game" do
        let(:max) { 2 }
        let(:dummy) { DummyModel.new(game: game, player: player) }
        let(:another_dummy) { DummyModel.create(game: game, player: player) }
        let(:second_dummy) { DummyModel.create(game: game, player: player) }
        before do
          DummyModel.max_per_game = max
          another_dummy; second_dummy
        end
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:game) }
        it { dummy.error_on(:game).should include I18n.t(have_more_error_translation_key) }
      end
    end
  end
end
