class GamesController < ApplicationController
  def index
    week = params[:week] || @current_league.week
    season = params[:season] || @current_league.season
    @games = @current_league.paginated_games season, week
  end
end
