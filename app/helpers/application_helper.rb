module ApplicationHelper
  def l_with_timezone(datetime, options = {})
    l datetime.in_time_zone(t('datetime.timezone')), options
  end
end
