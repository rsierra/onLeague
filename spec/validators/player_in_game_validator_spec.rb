require 'spec_helper'

describe PlayerInGameValidator do
  let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.player' }
  let(:any_club_error_translation_key) { "#{error_translation_key}.should_play_in_any_club" }

  before(:all) do
    build_model :dummy_models do
      integer :game_id
      integer :player_id

      belongs_to :game
      belongs_to :player

      validates :player, player_in_game: true
    end
    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { player: { should_play_in_any_club: 'Error message'} } } } }
    }
  end

  describe "when validate a model" do
    let(:game) { create(:game) }

    describe "with a player" do
      context "in home club" do
        let(:player) { create(:player_in_game, player_game: game) }
        let(:dummy) { DummyModel.new(game: game, player: player) }

        subject { dummy }

        it { should be_valid }
      end

      context "in away club" do
        let(:player) { create(:player_in_game_away, player_game: game) }
        let(:dummy) { DummyModel.new(game: game, player: player) }

        subject { dummy }

        it { should be_valid }
      end
    end

    context "with an invalid object" do
      let(:player) { create(:player) }
      let(:dummy) { DummyModel.new(game: game, player: player) }

      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { dummy.error_on(:player).should include I18n.t(any_club_error_translation_key) }
    end
  end
end