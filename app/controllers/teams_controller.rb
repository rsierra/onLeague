class TeamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @teams = current_user.teams.of_league(@current_league)
  end

  def show
    @team = current_user.teams.of_league(@current_league).find(params[:id])
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(params[:team])
    @team.user = current_user
    @team.league = @current_league

    if @team.save
      flash[:notice] = I18n.t('flash.teams.create_success')
      redirect_to team_path(@team)
    else
      render :new
    end
  end
end
