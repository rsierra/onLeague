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
    [[t('views.common.all'),'']] + @current_league.clubs.order(:name).map { |club| [club.name, club.id]}
  end

  def players_position_select_options
    [[t('views.common.all_feme'),'']] + ClubFile.position.options
  end

  def players_needed team
    sentence = TeamFile.position.values.map do |position|
      pluralize(team.needed_position(position), t("enumerize.team_file.position.#{position}").downcase) unless team.needed_position(position).zero?
    end.compact.to_sentence
    "#{t('.players_needed_at_least')} #{sentence}." unless sentence.blank?
  end

  def collection_index collection, element
    if collection.respond_to?(:last_page?) && !collection.last_page?
      per_page = collection.length
    else
      if collection.respond_to?(:total_count) && collection.respond_to?(:num_pages)
        per_page = collection.total_count - collection.length / collection.num_pages.pred
      end
    end
    page_offset = (collection.current_page - 1) * per_page.to_i if collection.respond_to? :current_page
    collection.index(element).next + page_offset.to_i
  end
end
