class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_league

  def set_league
    if League.active.count > 0
      session[:league_id] ||= League.active.first.id
      @league = League.active.exists?(session[:league_id]) ? League.active.find(session[:league_id]) : League.active.first
    else
      @league = League.new # If there aren´t leagues, we create an empty one to avoid errors
    end
  end
end
