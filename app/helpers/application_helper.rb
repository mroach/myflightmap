module ApplicationHelper
  def flag_img(country, size = 32)
    country = country.downcase # can't use downcase! when the strong is frozen
    country = "gb" if country == "uk"
    image_tag "flags/#{size}/#{country}.png"
  end

  # Eventually maybe support locale formatting
  def format_time(time)
    return nil if time.nil?
    time.strftime('%H:%M')
  end

  # Eventually maybe support locale formatting
  def format_date(date)
    return nil if date.nil?
    l date, format: :medium
  end

  # Hardcoded to km
  # Ex) 3,456 km
  def format_distance(distance, style = :long)
    return nil if distance.nil?
    if style == :short
      # 934267 => 934k
      s = number_to_human(distance, units: { thousand: 'k', million: 'm' }).sub(/\s/, '')
    else
      s = number_with_delimiter(distance)
    end
    "#{s} km"
  end

  # Format a duration with hours and minutes
  # Ex) 16h 45m
  def format_flight_duration(minutes)
    Duration.new(:minutes => minutes).format('%thh %mm')
  end

  def icon_link(link_text, link_path, icon_name, link_options = {})
    content_tag(:a, link_options.merge({href: link_path})) do
      content_tag(:i, "", class: "fa fa-#{icon_name}") + " " + content_tag(:span, link_text)
    end
  end
end
