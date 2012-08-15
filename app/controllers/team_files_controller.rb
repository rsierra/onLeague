# encoding: UTF-8

class TeamFilesController < ApplicationController
  before_filter :authenticate_user!, :find_team

  def new
    @team_file = TeamFile.new
    @club_files = ClubFile.active.current.page params[:page]
  end

  def create
    club_file = ClubFile.active.current.find params[:club_file_id]
    @team_file = @team.files.new(club_file.attributes_for_team_file)
    @team_file.date_in = Date.today
    if @team_file.save
      redirect_to team_path(@team)
    else
      @club_files = ClubFile.active.current.page params[:page]
      render :new
    end
  end

  def destroy
    if @team.files.destroy params[:id]
      flash[:notice] = I18n.t('flash.team_files.destroy_success')
    else
      flash[:error] = I18n.t('flash.team_files.destroy_error')
    end
    redirect_to team_path(@team)
  end

  private

  def find_team
    @team = current_user.teams.find params[:team_id]
  end
end
