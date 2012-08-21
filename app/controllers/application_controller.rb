class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale_from_url
  before_filter :set_league

  rescue_from Exception, with: :render_404 unless Rails.env.development?

  private

  def set_league
    if League.active.count > 0
      session[:league_id] ||= League.active.first.id
      @current_league = League.active.exists?(session[:league_id]) ? League.active.find(session[:league_id]) : League.active.first
    else
      @current_league = League.new # If there aren´t leagues, we create an empty one to avoid errors
    end
  end

  def render_404
    render template: 'error_pages/404', status: :not_found
  end

  def only_xhr
    render_404 unless request.xhr?
  end
end
