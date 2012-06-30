require 'spec_helper'

describe PlayerNotPlayYetValidator do
  let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.player' }
  let(:playing_error_translation_key) { "#{error_translation_key}.should_not_play_yet" }

  before(:all) do
    build_model :dummy_models do
      integer :game_id
      integer :player_id
      integer :minute, default: 100

      belongs_to :game
      belongs_to :player

      validates :player, player_not_play_yet: true
    end
    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { player: { should_not_play_yet: 'Error message'} } } } }
    }
  end

  describe "when validate a model" do
    let(:game) { create(:game) }
    let(:dummy) { DummyModel.new(game: game, player: player) }

    describe "with a player in home club" do
      context "not playing from the begin" do
        let(:player) { create(:player_with_club, player_club: game.club_home) }

        subject { dummy }

        it { should be_valid }

        context "after a substitution" do
          before { create(:substitution, game: game, player_in: player, minute: dummy.minute - 10)}

          subject { dummy }

          it { should_not be_valid }
          it { should have(1).error_on(:player) }
          it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
        end
      end

      context "playing from the begin" do
        let(:player) { create(:player_in_game, player_game: game) }

        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end
    end

    describe "with a player in away club" do
      context "not playing from the begin" do
        let(:player) { create(:player_with_club, player_club: game.club_away) }

        subject { dummy }

        it { should be_valid }

        context "after a substitution" do
          before { create(:substitution_away, game: game, player_in: player, minute: dummy.minute - 10)}

          subject { dummy }

          it { should_not be_valid }
          it { should have(1).error_on(:player) }
          it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
        end
      end

      context "playing from the begin" do
        let(:player) { create(:player_in_game_away, player_game: game) }

        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end
    end
  end
end
