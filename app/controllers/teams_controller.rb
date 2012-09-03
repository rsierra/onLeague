class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :only_xhr, only: [:search, :create_file, :destroy_file, :empty_cart, :checkout_cart]

  def index
    @teams = current_user.teams.of_league(@current_league)
  end

  def show
    load_team params[:id]
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
    load_team params[:team_id]
    club_file = ClubFile.active.current.find params[:club_file_id]

    if @team.active
      buy_player @team, club_file
    else
      @team_file = @team.files.build(club_file.attributes_for_team_file)
      if @team_file.save
        @team_file = @team.files.build
      else
        flash.now[:js_error] = I18n.t('flash.team_files.create_file_error')
      end
    end
    search_club_files
    render :show
  end

  def destroy_file
    load_team params[:team_id]
    if @team.active
      if @team.remaining_changes?
        sell_player @team, TeamFile.current.find(params[:team_file_id])
      else
        flash.now[:js_error] = I18n.t('flash.team_files.sell_player_error')
      end
    else
      if @team.files.destroy(params[:team_file_id])
        flash.now[:js_notice] = I18n.t('flash.team_files.destroy_success')
      else
        flash.now[:js_error] = I18n.t('flash.team_files.destroy_error')
      end
    end
    @team_file = @team.files.build
    search_club_files
    render :show
  end

  def activate
    load_team params[:team_id]
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
    load_team params[:team_id]
    search_club_files
    render partial: 'update_find_file'
  end

  def empty_cart
    load_team params[:team_id]
    session[@team.slug] = @team.file_cart = nil
    @team_file = @team.files.build
    search_club_files
    render :show
  end

  def checkout_cart
    load_team params[:team_id]
    checkout_error = @team.checkout_cart
    if checkout_error.blank?
      session[@team.slug] = @team.file_cart = nil
      flash.now[:js_notice] = I18n.t('flash.teams.checkout_cart_success')
    else
      flash.now[:js_error] = "#{I18n.t('flash.teams.checkout_cart_error')}: #{checkout_error}"
    end
    @team_file = @team.files.build
    search_club_files
    render :show
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
    per_page = 6
    @num_pages = ClubFile.active.current.of_clubs(@current_league.season_club_ids).search(params[:q]).result.count.next / per_page
    @club_files = @search.result.page(params[:page]).per(per_page)
  end

  def load_team id
    @team = current_user.teams.of_league(@current_league).find(id)
    @team.file_cart = session[@team.slug] if session[@team.slug]
  end

  def buy_player team, file
    session[team.slug] ||= Utils::Teams::FileCart.new
    session[team.slug].buy_player file
    team.file_cart = session[team.slug]
  end

  def sell_player team, file
    session[team.slug] ||= Utils::Teams::FileCart.new
    session[team.slug].sell_player file
    team.file_cart = session[team.slug]
  end
end
