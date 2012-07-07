require 'spec_helper'

describe PlayerPlayingValidator do
  let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes.player' }
  let(:playing_error_translation_key) { "#{error_translation_key}.should_be_playing" }

  before(:all) do
    build_model :dummy_models do
      integer :game_id
      integer :player_id
      integer :minute, default: 10

      belongs_to :game
      belongs_to :player

      validates :player, player_playing: true
    end
    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { player: { should_be_playing: 'Error message'} } } } }
    }
  end

  describe "when validate a model" do
    let(:game) { create(:game) }
    let(:dummy) { DummyModel.new(game: game, player: player) }

    describe "with a player in home club" do
      context "from the begin" do
        let(:player) { create(:player_in_game, player_game: game) }

        subject { dummy }

        it { should be_valid }
      end

      context "after a substitution" do
        let(:player) { create(:player_with_club, player_club: game.club_home) }

        before { create(:substitution, game: game, player_in: player, minute: dummy.minute - 10)}
        subject { dummy }

        it { should be_valid }

        context "and a red card" do
          before { create(:red_card, game: game, player: player, minute: dummy.minute - 5)}

          subject { dummy }

          it { should_not be_valid }
          it { should have(1).error_on(:player) }
          it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
        end

        context "and before a red card" do
          before { create(:red_card, game: game, player: player, minute: dummy.minute + 5)}

          subject { dummy }

          it { should be_valid }
        end
      end

      context "before a substitution" do
        let(:player) { create(:player_with_club, player_club: game.club_home) }

        before { create(:substitution, game: game, player_in: player, minute: dummy.minute + 10)}
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end

      context "after a red card" do
        let(:player) { create(:player_in_game, player_game: game) }

        before { create(:red_card, game: game, player: player, minute: dummy.minute - 10)}
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end

      context "before a red car" do
        let(:player) { create(:player_in_game, player_game: game) }

        before { create(:red_card, game: game, player: player, minute: dummy.minute + 10)}
        subject { dummy }

        it { should be_valid }
      end
    end

    describe "with a player in away club" do
      context "from the begin" do
        let(:player) { create(:player_in_game_away, player_game: game) }

        subject { dummy }

        it { should be_valid }
      end

      context "after a substitution" do
        let(:player) { create(:player_with_club, player_club: game.club_away) }

        before { create(:substitution_away, game: game, player_in: player, minute: dummy.minute - 10)}
        subject { dummy }

        it { should be_valid }

        context "and a red card" do
          before { create(:red_card, game: game, player: player, minute: dummy.minute - 5)}

          subject { dummy }

          it { should_not be_valid }
          it { should have(1).error_on(:player) }
          it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
        end

        context "and before a red card" do
          before { create(:red_card, game: game, player: player, minute: dummy.minute + 5)}

          subject { dummy }

          it { should be_valid }
        end
      end

      context "before a substitution" do
        let(:player) { create(:player_with_club, player_club: game.club_away) }

        before { create(:substitution_away, game: game, player_in: player, minute: dummy.minute + 10)}
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end

      context "after a red card" do
        let(:player) { create(:player_in_game, player_game: game) }

        before { create(:red_card, game: game, player: player, minute: dummy.minute - 10)}
        subject { dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player) }
        it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
      end

      context "before a red car" do
        let(:player) { create(:player_in_game, player_game: game) }

        before { create(:red_card, game: game, player: player, minute: dummy.minute + 10)}
        subject { dummy }

        it { should be_valid }
      end
    end

    context "with an invalid object" do
      let(:player) { create(:player) }

      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:player) }
      it { dummy.error_on(:player).should include I18n.t(playing_error_translation_key) }
    end
  end
end
