class HomeController < ApplicationController
  def index
    @users = User.latest
    @top_players = ClubFile.of_clubs(@current_league.season_club_ids)
      .order_by_points_on_season_week(@current_league.season, @current_league.current_week)
      .limit(5)
    @top_teams = Team.where(league_id: @current_league, season: @current_league.season)
      .order_by_points_on_season_week(@current_league.season, @current_league.current_week)
      .limit(5)
  end
end
