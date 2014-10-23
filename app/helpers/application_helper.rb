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

  # Hardcoded to km
  # Ex) 3,456 km
  def format_distance(distance)
    return nil if distance.nil?
    s = number_with_delimiter(distance)
    "#{s} km"
  end

  # Format a duration with hours and minutes
  # Ex) 16h 45m
  def format_flight_duration(minutes)
    Duration.new(:minutes => minutes).format('%thh %mm')
  end
end
