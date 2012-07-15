require 'spec_helper'

describe Player do
  describe "when create" do
    context "with correct data" do
      let(:player) { create(:player) }
      subject { player }
      it { should be_valid }
    end

    context "without name" do
      let(:player) { build(:player, name: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { player.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with duplicated name" do
      let(:player) { create(:player) }
      let(:duplicate_player) { build(:player, name: player.name) }
      before { duplicate_player.valid? }
      subject { duplicate_player }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { duplicate_player.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without born" do
      let(:player) { build(:player, born: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:born) }
      it { player.error_on(:born).should include I18n.t('errors.messages.blank') }
    end

    context "without active" do
      let(:player) { build(:player, active: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:active) }
      it { player.error_on(:active).should include I18n.t('errors.messages.inclusion') }
    end

    context "without eu" do
      let(:player) { build(:player, eu: nil) }
      subject { player }

      it { should_not be_valid }
      it { should have(1).error_on(:eu) }
      it { player.error_on(:eu).should include I18n.t('errors.messages.inclusion') }
    end

    context "without country" do
      let(:player) { build(:player, country: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:country_id) }
      it { player.error_on(:country_id).should include I18n.t('errors.messages.blank') }
    end
  end

  describe "with #last_date_out" do
    context "when not have club files" do
      let(:player) { create(:player) }
      subject { player }

      its(:last_date_out) { should be_nil }
    end

    context "when have one current club file" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player)}
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end

    context "when have one club file with date out" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player) }
      before { club_file.update_attributes(date_out: club_file.date_in.next) }
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end

    context "when have club file with date out and one current" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player)}
      before do
        club_file.update_attributes(date_out: club_file.date_in.next)
        create(:club_file, player: player, date_in: club_file.date_out.next)
      end
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end
  end

  context "when get active" do
    let(:player_active) { create(:player) }
    let(:player_inactive) { create(:player, active: false) }

    before { player_active; player_inactive }

    it { Player.active.should == [player_active] }
  end

  context "when update stats" do
    let(:game) { create(:game) }
    let(:player) { create(:player) }
    let(:points) { 1 }

    before { player.update_stats(game.id, points: points) }
    subject { player.stats.season(game.season).week(game.week).first }

    it { should_not be_nil }
    its(:points) { should eql points }

    context "and the player already has points" do
      let(:another_points) { 2 }
      before { player.update_stats(game.id, points: another_points) }
      subject { player.stats.season(game.season).week(game.week).first }

      it { player.should have(1).stats }
      it { should_not be_nil }
      its(:points) { should eql points + another_points}
    end

    context "and remove stats" do
      let(:another_points) { 2 }
      before { player.remove_stats(game.id, points: another_points) }
      subject { player.stats.season(game.season).week(game.week).first }

      it { player.should have(1).stats }
      it { should_not be_nil }
      its(:points) { should eql points - another_points}
    end
  end

  describe "when get played minutes" do
    let(:game) { create(:game) }

    context "in a played game" do
      let(:player) { create(:player_in_game, player_game: game) }
      subject { player }

      it { player.minutes_played_in_game(game.id).should eql Player::MAX_MINUTES }
    end

    context "in a not played game" do
      let(:player) { create(:player) }
      subject { player }

      it { player.minutes_played_in_game(game.id).should be_zero }
    end
  end

  describe "when get #club_on_date" do
    let(:club) { create(:club) }
    let(:player) { create(:player) }
    let(:date_in) { Date.yesterday }
    let(:club_file) { create(:club_file, player: player, club: club, date_in: date_in) }
    before { club_file }

    it { player.club_on_date.should eql club }
    it { player.club_on_date(date_in - 1.day).should be_nil }
    it { player.club_on_date(date_in).should eql club }
    it { player.club_on_date(date_in + 1.day).should eql club }

    context "and player changed club" do
      let(:new_club) { create(:club) }
      let(:date_out) { date_in + 1.week }
      let(:new_date_in) { date_out + 1.day }
      let(:new_date_out) { new_date_in + 1.week }
      let(:new_club_file) { create(:club_file, player: player, club: new_club, date_in: new_date_in) }
      before do
       club_file.update_attributes(date_out: date_out)
       new_club_file.update_attributes(date_out: new_date_out)
      end

      it { player.club_on_date(new_date_in - 1.day).should eql club }
      it { player.club_on_date(new_date_in).should eql new_club }
      it { player.club_on_date(new_date_in + 1.day).should eql new_club }
      it { player.club_on_date(new_date_out - 1.day).should eql new_club }
      it { player.club_on_date(new_date_out).should eql new_club }
      it { player.club_on_date(new_date_out + 1.day).should be_nil }
    end
  end

  describe "when get stats" do
    let(:player) { create(:player_with_club) }
    let(:player_stat) { create(:player_stat, player: player) }
    let(:league) { player_stat.game.league }
    let(:another_league) { create(:league) }
    before { player_stat }

    it { player.league_stats(:points, another_league).should be_zero  }
    it { player.league_stats(:goals_scored, another_league).should be_zero  }
    it { player.season_stats(:points, another_league).should be_zero  }
    it { player.season_stats(:goals_scored, another_league).should be_zero  }
    it { player.week_stats(:points, another_league).should be_zero  }
    it { player.week_stats(:goals_scored, another_league).should be_zero  }

    it { player.league_stats(:points, league).should eql player_stat.points  }
    it { player.league_stats(:goals_scored, league).should eql player_stat.goals_scored  }
    it { player.season_stats(:points, league).should eql player_stat.points }
    it { player.season_stats(:goals_scored, league).should eql player_stat.goals_scored  }
    it { player.week_stats(:points, league).should eql player_stat.points  }
    it { player.week_stats(:goals_scored, league).should eql player_stat.goals_scored  }

    context "with games in diferent seasons" do
      let(:another_game) { create(:game, league: league, season: league.season + 1, week: league.week)}
      let(:another_player_stat) { create(:player_stat, player: player, game: another_game) }
      before { another_player_stat }
      subject { player }

      it { player.league_stats(:points, league).should eql player_stat.points + another_player_stat.points  }
      it { player.league_stats(:goals_scored, league).should eql player_stat.goals_scored + another_player_stat.goals_scored  }
      it { player.season_stats(:points, league).should eql player_stat.points }
      it { player.season_stats(:goals_scored, league).should eql player_stat.goals_scored  }
      it { player.season_stats(:points, league, another_game.season).should eql another_player_stat.points }
      it { player.season_stats(:goals_scored, league, another_game.season).should eql another_player_stat.goals_scored  }
    end

    context "with games in diferent weeks" do
      let(:another_game) { create(:game, league: league, season: league.season, week: league.week + 1)}
      let(:another_player_stat) { create(:player_stat, player: player, game: another_game) }
      before { another_player_stat }
      subject { player }

      it { player.league_stats(:points, league).should eql player_stat.points + another_player_stat.points  }
      it { player.league_stats(:goals_scored, league).should eql player_stat.goals_scored + another_player_stat.goals_scored  }
      it { player.week_stats(:points, league).should eql player_stat.points }
      it { player.week_stats(:goals_scored, league).should eql player_stat.goals_scored  }
      it { player.week_stats(:points, league, another_game.season, another_game.week).should eql another_player_stat.points }
      it { player.week_stats(:goals_scored, league, another_game.season, another_game.week).should eql another_player_stat.goals_scored  }
    end
  end

  describe "when get #position_on_date" do
    let(:club) { create(:club) }
    let(:position) { 'defender' }
    let(:player) { create(:player) }
    let(:date_in) { Date.yesterday }
    let(:club_file) { create(:club_file, player: player, club: club, date_in: date_in, position: position) }
    before { club_file }

    it { player.position_on_date.should eql position }
    it { player.position_on_date(date_in - 1.day).should be_nil }
    it { player.position_on_date(date_in).should eql position }
    it { player.position_on_date(date_in + 1.day).should eql position }

    context "and change position" do
      let(:new_position) { 'forward' }
      before { club_file.update_attributes(position: new_position) }

      it { player.position_on_date(Date.yesterday).should eql position }
      it { player.position_on_date(Date.tomorrow).should eql new_position }
    end

    context "and player changed club" do
      let(:new_position) { 'forward' }
      let(:new_club) { create(:club) }
      let(:date_out) { date_in + 1.week }
      let(:new_date_in) { date_out + 1.day }
      let(:new_date_out) { new_date_in + 1.week }
      let(:new_club_file) { create(:club_file, player: player, club: new_club, date_in: new_date_in, position: new_position) }
      before do
       club_file.update_attributes(date_out: date_out)
       new_club_file.update_attributes(date_out: new_date_out)
      end

      it { player.position_on_date(new_date_in - 1.day).should eql position }
      it { player.position_on_date(new_date_in).should eql new_position }
      it { player.position_on_date(new_date_in + 1.day).should eql new_position }
      it { player.position_on_date(new_date_out - 1.day).should eql new_position }
      it { player.position_on_date(new_date_out).should eql new_position }
      it { player.position_on_date(new_date_out + 1.day).should be_nil }
    end
  end
end
