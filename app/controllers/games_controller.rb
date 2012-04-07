class GamesController < ApplicationController
  def index
    @games = @current_league.games.order(:date)
  end
end
