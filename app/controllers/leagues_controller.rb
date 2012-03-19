class LeaguesController < ApplicationController
  def change
    if League.active.count > 0
      @current_league = League.active.exists?(params[:id]) ? League.active.find(params[:id]) : League.first
      session[:league_id] = @current_league.id
    else
      @current_league = League.new # If there aren´t leagues, we create an empty one to avoid errors
    end
    redirect_to :root
  end
end
