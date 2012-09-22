class RankingsController < ApplicationController
  def index
    @season = params[:season] || @current_league.season

    @rankings = Team.where(league_id: @current_league, season: @season)
    @rankings = unless params[:week]
      @rankings.order_by_points_on_season(@season)
    else
      @week = params[:week] || @current_league.current_week
      @rankings.order_by_points_on_season_week(@season, @week)
    end
    @rankings = @rankings.page(params[:page])
  end
end
