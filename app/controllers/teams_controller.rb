class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :only_xhr, only: [:search, :create_file, :destroy_file]

  def index
    @teams = current_user.teams.of_league(@current_league)
  end

  def show
    @team = current_user.teams.of_league(@current_league).find(params[:id])
    @team_file = @team.files.build
    search_club_files
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

  def create_file
    @team = current_user.teams.of_league(@current_league).find(params[:team_id])
    club_file = ClubFile.active.current.find params[:club_file_id]
    @team_file = @team.files.build(club_file.attributes_for_team_file)
    @team_file.date_in = Date.today
    search_club_files
    if @team_file.save
      @team_file = @team.files.build
    end
    render :show
  end

  def destroy_file
    @team = current_user.teams.of_league(@current_league).find(params[:team_id])
    if !@team.active && @team.files.destroy(params[:team_file_id])
      flash[:notice] = I18n.t('flash.team_files.destroy_success')
    else
      flash[:error] = I18n.t('flash.team_files.destroy_error')
    end
    @team_file = @team.files.build
    search_club_files
    render :show
  end

  def activate
    @team = current_user.teams.of_league(@current_league).find(params[:team_id])
    @team.activate

    if @team.valid?
      flash[:notice] = I18n.t('flash.teams.activation_success')
      redirect_to team_path(@team)
    else
      flash[:error] = I18n.t('flash.teams.activation_error')
      redirect_to team_path(@team)
    end
  end

  def search
    @team = current_user.teams.of_league(@current_league).find(params[:team_id])
    search_club_files
    render partial: 'update_find_file'
  end

  private

  def search_club_files
    # Fix for kaminary paginator params, you have to nullify params
    # to get a clean url link
    @paginator_params = {}
    params.keys.each { |key| @paginator_params[key] = nil }
    @paginator_params.merge!( 'action' => 'search', 'controller' => 'teams',
      'team_id' => @team.slug, 'locale' => params[:locale], 'q' => params[:q])

    @search = ClubFile.active.current.of_clubs(@current_league.season_club_ids)
      .order_by_points_on_season(@current_league.season).order(:value)
      .search(params[:q])
    # There is a problem with kaminary and grouped scopes, becouse use count to get total pages
    # and gets a hash count, so we calculate total pages by hand to pass in pagination helper
    per_page = 5
    @num_pages = ClubFile.active.current.of_clubs(@current_league.season_club_ids).search(params[:q]).result.count / per_page + 1
    @club_files = @search.result.page(params[:page]).per(per_page)
  end
end
