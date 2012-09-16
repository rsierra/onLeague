class HomeController < ApplicationController
  def index
    @users = User.latest
    @last_winner = Team.where(league_id: @current_league, season: @current_league.season)
      .order_by_points_on_season_week(@current_league.season, @current_league.last_week)
      .limit(1).first
    @top_players = ClubFile.active.current.of_clubs(@current_league.season_club_ids)
      .order_by_points_on_season_week(@current_league.season, @current_league.current_week)
      .limit(5)
    @top_teams = Team.where(league_id: @current_league, season: @current_league.season)
      .order_by_points_on_season_week(@current_league.season, @current_league.current_week)
      .limit(5)
  end
end
