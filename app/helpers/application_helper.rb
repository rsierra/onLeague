module ApplicationHelper
  def l_with_timezone(datetime, options = {})
    l datetime.in_time_zone(t('datetime.timezone')), options
  end

  def default_locale? locale
    I18n.default_locale == locale
  end

  def language_selector
    I18n.available_locales.map do |locale|
      link_to(locale, default_locale?(locale) ? "/" : "/#{locale}")
    end.join(' | ')
  end

  def current_league_select_options
    [[t('views.common.all'),'']] + @current_league.clubs.map { |club| [club.name, club.id]}
  end

  def players_position_select_options
    [[t('views.common.all_feme'),'']] + ClubFile.position.options
  end
end
