module PlayerHelper
  def jersey_with_number file
    number_color = "#{file.club.number_color}"
    border_color = "#{file.club.border_color}"
    border_style =  "0.1em 0.1em #{border_color}," +
                    "-0.1em -0.1em #{border_color}," +
                    "0.1em -0.1em #{border_color}," +
                    "-0.1em 0.1em #{border_color}"
    content_tag(:div, class: :jersey) do
      content_tag(:span, file.player.file.number, style: "color: #{number_color}; text-shadow: #{border_style}") +
      image_tag(file.club.jersey.url(:thumb),
        alt: "#{file.club.name} #{Club.human_attribute_name(:jersey)}")
    end
  end

  def country_flag file
    flag = image_tag file.player.country.flag.url(:small),
        alt: "#{file.player.country.name} #{Country.human_attribute_name(:flag)}"
    flag += image_tag 'icons/no-eu.png', alt: "#{Player.human_attribute_name(:eu)}" unless file.player.eu
    flag
  end
end
