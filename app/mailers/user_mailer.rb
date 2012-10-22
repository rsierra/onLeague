class UserMailer < ActionMailer::Base
  default :from => "no-replay@onleague.org"

  def points_notification(team)
    @user_name = team.user.name
    @week = team.league.last_week
    @league_name = team.league.name
    @team_name = team.name
    @points = team.season_week_points(team.league.season, @week)
    mail(:to => team.user.email,
         :subject => I18n.t('points_notification_subject', scope: "mailers.user_mailers", team_name: @team_name))
  end

  def inactive_notification(team)
    @team = team
    @user_name = team.user.name
    @week = team.league.last_week
    @league_name = team.league.name
    mail(:to => team.user.email,
         :subject => I18n.t('inactive_notification_subject', scope: "mailers.user_mailers", team_name: @team.name))
  end

end
