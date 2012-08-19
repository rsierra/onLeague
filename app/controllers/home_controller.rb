class HomeController < ApplicationController
  def index
    @users = User.latest
    @top_club_files = ClubFile.of_clubs(@current_league.season_club_ids)
      .order_by_points_on_season_week(@current_league.season, @current_league.current_week)
      .limit(5)
  end
end
