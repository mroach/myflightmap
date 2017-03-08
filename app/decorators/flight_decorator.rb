class FlightDecorator < Draper::Decorator
  delegate_all

  def title
    title = object.description
    title << " - Private" if object.private?
  end

  def css_classes
    [private_css_class, seat_class_css_class]
  end

  def private_css_class
    "private" if object.private?
  end

  def seat_description
    desc = "#{object.seat}"
    desc << " (%s)" % object.seat_location unless object.seat_location.blank?
    desc.strip
  end

  def time_remaining(refdate = Time.now.utc)
    object.in_the_air?(refdate) ? (refdate - object.arrive_time_utc) : 0
  end

  # Desired results depending on what's available:
  # Business on Lufthansa
  # Business
  # Lufthansa
  def class_on_airline
    parts = []
    parts << object.seat_class
    parts.reject!(&:blank?)
    unless object.airline_name.blank?
      parts << " " << h.t('words.on') unless parts.empty?
      parts << object.airline_name
    end
    parts.join(' ').strip
  end

  # Get a description of the time change between airports
  # nil when there is none
  # Examples with style = "long":
  #  CPH-SIN: "SIN is 6 hours ahead of CPH"
  #  BKK-SIN: "SIN is 1 hour ahead of BKK"
  #  BKK-RGN: "RGN is 30 minutes behind BKK"
  #  ZRH-BOM: "BOM is 4 hours 30 minutes ahead of ZRH"
  # Examples with style = "short":
  #  CPH-SIN: +6h
  #  BKK-SIN: +1h
  #  BKK-RGN: -30m
  #  ZRH-BOM: +4h30m
  def time_change_desc(style = :long)
    return nil if object.time_change == 0
    formatted = h.format_duration(object.time_change, style)

    if style == :short
      sign = object.time_change > 0 ? '+' : '-'
      return "#{sign}#{formatted}"
    end

    I18n.t(object.time_change > 0 ? 'time_ahead' : 'time_behind',
           origin:      object.depart_city,
           destination: object.arrive_city,
           time:        formatted)
  end

  # Represents days forward or back for the arrival date
  # E.g) Flying overnight from the US to Europe, +1
  def arrive_time_offset
    offset = (object.arrive_date - object.depart_date).to_i
    case
    when offset < 0 then "-#{offset}"
    when offset > 0 then "+#{offset}"
      else ""
    end
  end

  # Aircraft model plus the registration and aircraft name if available
  def aircraft_description
    s = aircraft_type

    extra = []
    extra.push aircraft_registration unless aircraft_registration.nil?
    extra.push "\"#{aircraft_name}\"" unless aircraft_name.nil?

    if !extra.empty?
      s = "#{s} (#{extra.join(' ')})"
    end
    s
  end

  def seat_class_css_class
    return nil if object.seat_class.blank?
    object.seat_class.downcase.sub(/\W/, '')
  end

  def static_map_image_tag(width: 500, height: 300)
    return if object.depart_airport_info.nil? || object.arrive_airport_info.nil?

    url = "https://maps.googleapis.com/maps/api/staticmap"
    query = {
      size: "#{width}x#{height}",
      key:  ENV['GOOGLE']
    }

    depart_latlon = "#{object.depart_airport_info.latitude},#{object.depart_airport_info.longitude}"
    arrive_latlon = "#{object.arrive_airport_info.latitude},#{object.arrive_airport_info.longitude}"

    paths = [depart_latlon, arrive_latlon].join('|')
    query[:path] = "color:0x0000ff|weight:5|#{paths}"

    markers = [
      { icon: "http://myflightmap.com/images/departing.png", point: depart_latlon },
      { icon: "http://myflightmap.com/images/arriving.png", point: arrive_latlon },
    ].map do |m|
      "markers=size:mid|icon:#{m[:icon]}|shadow:true|#{m[:point]}"
    end

    h.image_tag "#{url}?#{query.to_query}&#{markers.join('&')}"
  end

  def seat_class_label
    return nil if object.seat_class.blank?
    h.content_tag(:span, class: ["seat_class", seat_class_css_class].join(' ')) do
      object.seat_class
    end
  end
end
