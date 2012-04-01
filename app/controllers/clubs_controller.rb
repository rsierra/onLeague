class ClubsController < ApplicationController
  def index
    @clubs = @current_league.clubs.order(:name)
  end

  def show
    @club = @current_league.clubs.find params[:id]
  end
end
