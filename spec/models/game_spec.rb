require 'spec_helper'

describe Game do
  let(:error_translation_key) { 'activerecord.errors.models.game.attributes' }
  let(:home_play_same_league_error_translation_key) { "#{error_translation_key}.club_home.should_play_same_league" }
  let(:away_play_same_league_error_translation_key) { "#{error_translation_key}.club_away.should_play_same_league" }
  let(:cant_play_himself_error_translation_key) { "#{error_translation_key}.club_home.cant_play_himself" }
  let(:initial_status_error_translation_key) { "#{error_translation_key}.status.should_be_initial_status" }
  let(:accepted_status_error_translation_key) { "#{error_translation_key}.status.should_be_an_accepted_status" }
  let(:number_of_lineups_error_translation_key) { "#{error_translation_key}.lineups.should_have_right_number_of_lineups" }

  describe "when create" do

    context "with correct data" do
      let(:game) { create(:game) }
      subject { game }

      it { should be_valid }
      its(:name) { should eq "#{game.club_home.name} - #{game.club_away.name}" }
      its(:home_goals) { should eq 0 }
      its(:away_goals) { should eq 0 }
    end

    context "after a find" do
      let(:game) { create(:game) }
      before { game }
      subject { Game.find game }

      its(:name) { should eq "#{game.club_home.name} - #{game.club_away.name}" }
    end

    context "without date" do
      let(:game) { build(:game, date: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:date) }
      it { game.error_on(:date).should include I18n.t('errors.messages.blank') }
    end

    context "without status" do
      let(:game) { build(:game, status: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:status) }
      it { game.error_on(:status).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:status).should include I18n.t('errors.messages.inclusion') }
    end

    context "with no initial status" do
      let(:game) { build(:game, status: 'evaluated') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:status) }
      it { game.error_on(:status).should include I18n.t(initial_status_error_translation_key) }
    end

    context "without week" do
      let(:game) { build(:game, week: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(3).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:week).should include I18n.t('errors.messages.too_short', count: 1) }
    end

    context "with not number week" do
      let(:game) { build(:game, week: 'a') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with float week" do
      let(:game) { build(:game, week: '.1') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "with week less than 0" do
      let(:game) { build(:game, week: -1) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.greater_than', count: 0) }
    end

    context "with week more than two dgits" do
      let(:game) { build(:game, week: 100) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { game.error_on(:week).should include I18n.t('errors.messages.too_long', count: 2) }
    end

    context "without season" do
      let(:game) { build(:game, season: nil) }
      subject { game }

      it { should_not be_valid }
      it { should have(3).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.blank') }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with not number season" do
      let(:game) { build(:game, season: 'a') }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with float season" do
      let(:game) { build(:game, season: '1111.1') }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "with season less than 0" do
      let(:game) { build(:game, season: -1) }
      subject { game }

      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.greater_than', count: 0) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with season less than four digits" do
      let(:game) { build(:game, season: 100) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "with season more than four digits" do
      let(:game) { build(:game, season: 10000) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { game.error_on(:season).should include I18n.t('errors.messages.wrong_length', count: 4) }
    end

    context "without clubs in same league" do
      let(:club) { build(:club) }
      let(:game) { build(:game, club_home: club) }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:club_home) }
      it { game.error_on(:club_home).should include I18n.t(home_play_same_league_error_translation_key) }
      it { should have(1).error_on(:club_away) }
      it { game.error_on(:club_away).should include I18n.t(away_play_same_league_error_translation_key) }
    end

    context "with same club" do
      let(:game) { build(:game) }
      before { game.club_away = game.club_home }
      subject { game }

      it { should_not be_valid }
      it { should have(1).error_on(:club_home) }
      it { game.error_on(:club_home).should include I18n.t(cant_play_himself_error_translation_key) }
    end

    context "with one home goals" do
      let(:game) { create(:game) }
      let(:goal) { create(:goal, game: game) }
      before { goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eq 1 }
      its(:away_goals) { should eq 0 }
    end

    context "with home goals" do
      let(:game) { create(:game) }
      let(:goal) { create(:goal, game: game) }
      let(:second_goal) { create(:goal, game: game) }
      before { goal; second_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eq 2 }
      its(:away_goals) { should eq 0 }
    end

    context "with one away goals" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_in_game_away, player_game: game) }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      before { goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eq 0 }
      its(:away_goals) { should eq 1 }
    end

    context "with away goals" do
      let(:game) { create(:game) }
      let(:scorer) { create(:player_in_game_away, player_game: game) }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      let(:second_goal) { create(:goal, game: game, scorer: scorer) }
      before { goal; second_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eq 0 }
      its(:away_goals) { should eq 2 }
    end

    context "with away goals" do
      let(:game) { create(:game) }
      let(:home_scorer) { create(:player_in_game, player_game: game) }
      let(:away_scorer) { create(:player_in_game_away, player_game: game) }
      let(:goal) { create(:goal, game: game, scorer: home_scorer) }
      let(:second_goal) { create(:goal, game: game, scorer: home_scorer) }
      let(:third_goal) { create(:goal, game: game, scorer: away_scorer) }
      before { goal; second_goal; third_goal }
      subject { game }

      it { should be_valid }
      its(:home_goals) { should eq 2 }
      its(:away_goals) { should eq 1 }
    end

    context "with players" do
      let(:player) { create(:player_with_club) }
      let(:game) { create(:game_from_club_home, club_home: player.club) }
      subject { game }

      it { game.player_in_club_home?(player).should be_true }
      it { game.player_in_club_away?(player).should_not be_true }
    end
  end

  context "when get games of a week" do
    let(:game) { create(:game, week: 1) }
    let(:second_game) { create(:game, week: 1) }
    let(:third_game) { create(:game, week: 2) }

    before { game; second_game; third_game }

    it { Game.week(1).should eq [game, second_game] }
    it { Game.week(2).should eq [third_game] }
    it { Game.week(3).should be_empty }
  end

  context "when get games of a season" do
    let(:game) { create(:game, season: 2001) }
    let(:second_game) { create(:game, season: 2001) }
    let(:third_game) { create(:game, season: 2002) }

    before { game; second_game; third_game }

    it { Game.season(2001).should eq [game, second_game] }
    it { Game.season(2002).should eq [third_game] }
    it { Game.season(2003).should be_empty }
  end

  context "when get #goalkeeper_in_club_id_on_minute" do
    let(:game) { create(:game) }
    let(:minute) { 45 }

    it { game.goalkeeper_in_club_id_on_minute(game.club_home_id,minute).should be_nil }
    it { game.goalkeeper_against_club_id_on_minute(game.club_home_id,minute).should be_nil }

    it { game.goalkeeper_in_club_id_on_minute(game.club_away_id,minute).should be_nil }
    it { game.goalkeeper_against_club_id_on_minute(game.club_away_id,minute).should be_nil }

    context "with goalkeeper" do
      let(:goalkeeper) { create(:player_in_game, player_game: game, player_position: 'goalkeeper')}
      before { goalkeeper }

      it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, 1).should eq goalkeeper }
      it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, 45).should eq goalkeeper }
      it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, 90).should eq goalkeeper }

      it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, 1).should eq goalkeeper }
      it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, 45).should eq goalkeeper }
      it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, 90).should eq goalkeeper }

      context "and is expulsed" do
        let(:card) { create(:card, :direct_red, game: game, player: goalkeeper, minute: minute) }
        before { card }

        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute - 1).should eq goalkeeper }
        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute).should eq goalkeeper }
        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute + 1).should be_nil }

        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute - 1).should eq goalkeeper }
        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute).should eq goalkeeper }
        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute + 1).should be_nil }

        context "and then another goalkeeper get in" do
          let(:defender) { create(:player_in_game, player_game: game, player_position: 'defender')}
          let(:another_goalkeeper) { create(:player_with_club, player_club: game.club_home, player_position: 'goalkeeper')}
          let(:substitution) { create(:substitution, game: game, player_out: defender, player_in: another_goalkeeper, minute: minute) }
          before { substitution }

          it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute - 1).should eq goalkeeper }
          it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute).should eq goalkeeper }
          it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute + 1).should eq another_goalkeeper }

          it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute - 1).should eq goalkeeper }
          it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute).should eq goalkeeper }
          it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute + 1).should eq another_goalkeeper }

          context "that is expulsed again" do
            let(:another_minute) { minute + 10 }
            let(:another_card) { create(:card, :direct_red, game: game, player: another_goalkeeper, minute: another_minute) }
            before { another_card }

            it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, another_minute - 1).should eq another_goalkeeper }
            it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, another_minute).should eq another_goalkeeper }
            it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, another_minute + 1).should be_nil }

            it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, another_minute - 1).should eq another_goalkeeper }
            it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, another_minute).should eq another_goalkeeper }
            it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, another_minute + 1).should be_nil }
          end
        end
      end

      context "and is substituted by another goalkeeper" do
        let(:another_goalkeeper) { create(:player_with_club, player_club: game.club_home, player_position: 'goalkeeper')}
        let(:substitution) { create(:substitution, game: game, player_out: goalkeeper, player_in: another_goalkeeper, minute: minute) }
        before { substitution }

        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute - 1).should eq goalkeeper }
        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute).should eq goalkeeper }
        it { game.goalkeeper_in_club_id_on_minute(game.club_home_id, minute + 1).should eq another_goalkeeper }

        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute - 1).should eq goalkeeper }
        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute).should eq goalkeeper }
        it { game.goalkeeper_against_club_id_on_minute(game.club_away_id, minute + 1).should eq another_goalkeeper }
      end
    end
  end

  describe "when change status" do
    let(:game) { create(:game) }
    before { game.stub(:valid_lineups_count?).and_return(true) }

    describe "from active" do
      context "to inactive" do
        before { game.status = 'inactive' }
        subject { game }

        it { should be_valid }
      end

      context "to evaluated" do
        before { game.status = 'evaluated' }

        subject { game }

        it { should be_valid }
      end

      context "to revised" do
        before { game.status = 'revised' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to closed" do
        before { game.status = 'closed' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end
    end

    describe "from inactive" do
      let(:game) { create(:game, status: 'inactive')}
      context "to active" do
        before { game.status = 'inactive' }
        subject { game }

        it { should be_valid }
      end

      context "to evaluated" do
        before { game.status = 'evaluated' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to revised" do
        before { game.status = 'revised' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to closed" do
        before { game.status = 'closed' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end
    end

    describe "from evaluated" do
      before { game.update_attributes(status: 'evaluated') }
      context "to active" do
        before { game.status = 'active' }
        subject { game }

        it { should be_valid }
      end

      context "to revised" do
        before { game.status = 'revised' }
        subject { game }

        it { should be_valid }
      end

      context "to inactive" do
        before { game.status = 'inactive' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to closed" do
        before { game.status = 'closed' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end
    end

    describe "from revised" do
      before do
        game.update_attributes(status: 'evaluated')
        game.update_attributes(status: 'revised')
      end
      context "to evaluated" do
        before { game.status = 'evaluated' }
        subject { game }

        it { should be_valid }
      end

      context "to closed" do
        before { game.status = 'closed' }
        subject { game }

        it { should be_valid }
      end

      context "to inactive" do
        before { game.status = 'inactive' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to active" do
        before { game.status = 'active' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end
    end

    describe "from closed" do
      before do
        game.update_attributes(status: 'evaluated')
        game.update_attributes(status: 'revised')
        game.update_attributes(status: 'closed')
      end
      context "to revised" do
        before { game.status = 'revised' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to inactive" do
        before { game.status = 'inactive' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to active" do
        before { game.status = 'active' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end

      context "to evaluated" do
        before { game.status = 'evaluated' }
        subject { game }

        it { should_not be_valid }
        it { should have(1).error_on(:status) }
        it { game.error_on(:status).should include I18n.t(accepted_status_error_translation_key) }
      end
    end
  end

  describe "when evaluate" do
    let(:game) { create(:game) }
    before { game.update_attributes(status: 'evaluated') }
    subject { game }

    context "with enought lineups" do
      let(:game) { create(:game, :full_of_lineups) }

      it { should be_valid }
    end

    context "without lineups" do
      it { should_not be_valid }
      it { should have(1).error_on(:lineups) }
      it { game.error_on(:lineups).should include I18n.t(number_of_lineups_error_translation_key) }
    end

    context "without enought lineups" do
      let(:game) { create(:game, :full_of_lineups, home_lineups: Lineup.max_per_game - 1, away_lineups: Lineup.max_per_game - 1) }

      it { should_not be_valid }
      it { should have(1).error_on(:lineups) }
      it { game.error_on(:lineups).should include I18n.t(number_of_lineups_error_translation_key) }
    end

    context "without enought lineups in club home" do
      let(:game) { create(:game, :full_of_lineups, home_lineups: Lineup.max_per_game - 1) }

      it { should_not be_valid }
      it { should have(1).error_on(:lineups) }
      it { game.error_on(:lineups).should include I18n.t(number_of_lineups_error_translation_key) }
    end

    context "without enought lineups in club home" do
      let(:game) { create(:game, :full_of_lineups, away_lineups: Lineup.max_per_game - 1) }

      it { should_not be_valid }
      it { should have(1).error_on(:lineups) }
      it { game.error_on(:lineups).should include I18n.t(number_of_lineups_error_translation_key) }
    end
  end


  describe "when evaluate" do
    let(:game) { create(:game) }
    before { game.stub(:valid_lineups_count?).and_return(true) }

    describe "without goals" do
      before do
        player
        game.update_attributes(status: 'evaluated')
      end

      subject { player.stats.week(game.week).season(game.season).first }

      context "a normal player" do
        let(:player) { create(:player_in_game, player_game: game) }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a defender" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'defender') }

        its(:points) { should eq 3 }
        its(:points) { should eq Lineup::STATS[:points] + Game::UNBEATEN_DEFENDER_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a goalkeeper" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'goalkeeper') }

        its(:points) { should eq 4 }
        its(:points) { should eq Lineup::STATS[:points] + Game::UNBEATEN_GOALKEEPER_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end
    end

    describe "with a goal against" do
      let(:scorer) { create(:player_in_game_away, player_game: game, player_position: 'forward') }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      before do
        player; goal
        game.update_attributes(status: 'evaluated')
      end

      subject { player.stats.week(game.week).season(game.season).first }

      context "a normal player" do
        let(:player) { create(:player_in_game, player_game: game) }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a defender" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'defender') }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a goalkeeper" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'goalkeeper') }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] + Goal::CONCEDED_STAT[:points] + Game::BEATEN_GOALKEEPER_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 1 }
          its(:points) { should eq Lineup::STATS[:points] + Goal::CONCEDED_STAT[:points] }
        end
      end
    end

    describe "with more than a goal against" do
      let(:scorer) { create(:player_in_game_away, player_game: game, player_position: 'forward') }
      let(:first_goal) { create(:goal, game: game, scorer: scorer) }
      let(:second_goal) { create(:goal, game: game, scorer: scorer) }

      before do
        player; first_goal; second_goal
        game.update_attributes(status: 'evaluated')
      end

      subject { player.stats.week(game.week).season(game.season).first }

      context "a normal player" do
        let(:player) { create(:player_in_game, player_game: game) }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a defender" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'defender') }

        its(:points) { should eq 2 }
        its(:points) { should eq Lineup::STATS[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "a goalkeeper" do
        let(:player) { create(:player_in_game, player_game: game, player_position: 'goalkeeper') }

        its(:points) { should eq 0 }
        its(:points) { should eq Lineup::STATS[:points] + Goal::CONCEDED_STAT[:points] + Goal::CONCEDED_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 0 }
          its(:points) { should eq Lineup::STATS[:points] + Goal::CONCEDED_STAT[:points] + Goal::CONCEDED_STAT[:points] }
        end
      end
    end

    describe "and there is winner" do
      let(:scorer) { create(:player_in_game, player_game: game, player_position: 'forward') }
      let(:player) { create(:player_in_game, player_game: game) }
      let(:goal) { create(:goal, game: game, scorer: scorer) }
      before do
        player; goal
        game.update_attributes(status: 'evaluated')
      end

      context "a normal player" do
        subject { player.stats.week(game.week).season(game.season).first }

        its(:points) { should eq 3 }
        its(:points) { should eq Lineup::STATS[:points] + Game::WINNER_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 2 }
          its(:points) { should eq Lineup::STATS[:points] }
        end
      end

      context "the scorer" do
        subject { scorer.stats.week(game.week).season(game.season).first }

        its(:points) { should eq 5 }
        its(:points) { should eq Lineup::STATS[:points] + goal.scorer_stats[:points] + Game::WINNER_STAT[:points] }

        context "and undo evaluate" do
          before { game.update_attributes(status: 'active') }

          its(:points) { should eq 4 }
          its(:points) { should eq Lineup::STATS[:points] + goal.scorer_stats[:points] }
        end
      end
    end
  end

  describe "when get evaluated games" do
    let(:league) { create(:league) }
    let(:games) { create_list(:game, 4, league: league).sort }

    before do
      games[1].update_attribute(:status, 'evaluated')
      games[2].update_attribute(:status, 'revised')
      games[3].update_attribute(:status, 'closed')
    end

    it { Game.evaluated.should_not include games.first }
    it { Game.evaluated.should eq games.drop(1) }
  end

  describe "when get games on a time" do
    let(:league) { create(:league) }
    let(:date_time) { DateTime.now }
    let(:game) { create(:game, league: league, date: date_time) }
    before { game }

    it { Game.playing(date_time - 1.hour).should be_empty }
    it { Game.playing(date_time - Game::TIME_BEFORE).should eq [game] }
    it { Game.playing(date_time).should eq [game] }
    it { Game.playing(date_time + 1.hour).should eq [game] }
    it { Game.playing(date_time + Game::TIME_AFTER).should eq [game] }
    it { Game.playing(date_time + 3.hour).should be_empty }
  end

  describe "when get games played" do
    let(:league) { create(:league) }
    let(:date_time) { DateTime.now }
    let(:game) { create(:game, league: league, date: date_time) }
    before { game }

    it { Game.played(date_time - 1.hour).should be_empty }
    it { Game.played(date_time - Game::TIME_BEFORE).should eq [game] }
    it { Game.played(date_time).should eq [game] }
    it { Game.played(date_time + 1.hour).should eq [game] }
    it { Game.played(date_time + Game::TIME_AFTER).should eq [game] }
    it { Game.played(date_time + 3.hour).should eq [game] }

    context "next week" do
      let(:next_week_date_time) { date_time + 7.days }
      let(:next_week_game) { create(:game, league: league, date: next_week_date_time) }
      before do
        game
        league.update_attributes(week: league.week + 1)
        next_week_game
      end

      it { Game.played(date_time).should be_empty }
      it { Game.played(next_week_date_time - 1.hour).should be_empty }
      it { Game.played(next_week_date_time - Game::TIME_BEFORE).should eq [next_week_game] }
      it { Game.played(next_week_date_time).should eq [next_week_game] }
      it { Game.played(next_week_date_time + 1.hour).should eq [next_week_game] }
      it { Game.played(next_week_date_time + Game::TIME_AFTER).should eq [next_week_game] }
      it { Game.played(next_week_date_time + 3.hour).should eq [next_week_game] }
    end
  end
end
