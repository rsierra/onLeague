class RankingsController < ApplicationController
  def index
    @season = params[:season] || @current_league.season

    @ranking_kind = params[:week] ? 'weekly' : 'seasonal'
    @ranking_kind += "_#{params[:provider]}" if params[:provider]

    @rankings = Team.where(league_id: @current_league, season: @season)
    if @current_user && params[:provider]
      @provider = params[:provider]
      provider_conditions = { provider: @provider, uid: @current_user.provider_friends(@provider) }
      user_ids = User.select('users.id').joins(:oauth_providers).where(oauth_providers: provider_conditions).map(&:id)
      user_ids << @current_user.id
      @rankings = @rankings.of_user(user_ids)
    end
    @rankings = unless params[:week]
      @rankings.order_by_points_on_season(@season)
    else
      @week = params[:week] || @current_league.current_week
      @rankings.order_by_points_on_season_week(@season, @week)
    end
    @rankings = @rankings.page(params[:page])
  end
end
