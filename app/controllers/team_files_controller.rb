# encoding: UTF-8

class TeamFilesController < ApplicationController
  before_filter :authenticate_user!, :find_team

  def new
    @team_file = TeamFile.new
    search_club_files
  end

  def search
    new
    render :new
  end

  def create
    club_file = ClubFile.active.current.find params[:club_file_id]
    @team_file = @team.files.new(club_file.attributes_for_team_file)
    @team_file.date_in = Date.today
    if @team_file.save
      redirect_to team_path(@team)
    else
      search_club_files
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

  def search_club_files
    @search = ClubFile.of_clubs(@current_league.season_club_ids).order_by_points.search(params[:q])
    # There is a problem with kaminary and grouped scopes, becouse use count to get total pages
    # and gets a hash count, so we calculate total pages by hand to pass in pagination helper
    per_page = 10
    @num_pages = ClubFile.of_clubs(@current_league.season_club_ids).count / per_page
    @club_files = @search.result.page(params[:page]).per(per_page)
  end
end
