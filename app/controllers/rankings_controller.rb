class RankingsController < ApplicationController
  def index
    @rankings = Team.where(league_id: @current_league, season: @current_league.season)
      .order_by_points_on_season(@current_league.season)
      .page(params[:page])
  end
end
