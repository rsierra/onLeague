class GamesController < ApplicationController
  def index
    week = params[:week] || @current_league.week
    @season = params[:season] || @current_league.season

    @weeks = Kaminari.paginate_array(@current_league.season_week_list(@season)).page(week).per(1)
    @seasons = @current_league.season_list
    @season = @season
    @games = @current_league.games.season(@season).week(week)
  end

  def show
    @game = Game.find(params[:id])
  end
end
