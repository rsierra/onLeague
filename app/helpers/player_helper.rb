module PlayerHelper
  def jersey_with_number file, size = :thumb
    number_color = "#{file.club.number_color}"
    border_color = "#{file.club.border_color}"
    border_style =  "0.1em 0.1em #{border_color}," +
                    "-0.1em -0.1em #{border_color}," +
                    "0.1em -0.1em #{border_color}," +
                    "-0.1em 0.1em #{border_color}"
    content_tag(:div, class: "jersey-#{size}") do
      content_tag(:span, file.player.file.number, style: "color: #{number_color}; text-shadow: #{border_style}") +
      image_tag(file.club.jersey.url(size),
        alt: "#{file.club.name} #{Club.human_attribute_name(:jersey)}")
    end
  end

  def country_flag file
    flag = image_tag file.player.country.flag.url(:small),
        alt: "#{file.player.country.name} #{Country.human_attribute_name(:flag)}"
    flag += image_tag 'icons/no-eu.png', alt: "#{Player.human_attribute_name(:eu)}" unless file.player.eu
    flag
  end

  def link_to_modal_player_file player_file
    modal_id = "#{player_file.class.name.underscore.dasherize}-#{player_file.id}-info"
    content_for(:modals) do
      content_tag(:div, class: "modal hide", id: modal_id) do
        content_tag(:div, class: "modal-header") do
          button_tag('x', class: "close", 'data-dismiss' => "modal") +
          content_tag(:h3, player_file.player_name)
        end +
        content_tag(:div, '', class: "modal-body") +
        content_tag(:div, class: "modal-footer") do
          link_to t('views.common.close'), "#", class: "btn", 'data-dismiss' => "modal"
        end
      end
    end
    link_to(player_file.player_name, [player_file], 'data-toggle' => 'modal',
      'data-target' => "##{modal_id}")
  end
end
