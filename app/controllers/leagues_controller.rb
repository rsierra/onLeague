class LeaguesController < ApplicationController
  def change
    if League.active.count > 0
      @league = League.active.exists?(params[:id]) ? League.active.find(params[:id]) : League.first
      session[:league_id] = @league.id
    else
      @league = League.new # If there aren´t leagues, we create an empty one to avoid errors
    end
    redirect_to :root
  end
end
