module RankingHelper
  def ranking_nav_item ranking_kind, item_kind, icon = nil, path_options = {}
    content_tag(:li, class: ('active' if ranking_kind == item_kind)) do
      link_to rankings_path(path_options) do
        link = t(".#{item_kind}")
        link = content_tag(:i, '', class: icon) + link if icon
        link
      end
    end
  end
end
