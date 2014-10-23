module FlightsHelper

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
  def time_change_desc(flight, style = "long")
    return nil if flight.time_change == 0
    formatted = format_duration(flight.time_change, style)

    if style == "short"
      sign = flight.time_change > 0 ? '+' : '-'
      return "#{sign}#{formatted}"
    end

    I18n.t(flight.time_change > 0 ? 'time_ahead' : 'time_behind',
      origin: flight.depart_city,
      destination: flight.arrive_city,
      time: formatted)
  end

  private

  def format_duration(minutes, style = "short")
    change = Duration.new(:minutes => minutes)
    time_label = case
      when change.total < 3600 then 'minutes'
      when change.total % 3600 != 0 then'hours_minutes'
      else 'hours'
    end
    time_label = "duration.formats.#{time_label}.#{style}"
    change.format(I18n.t(time_label))
  end
end
