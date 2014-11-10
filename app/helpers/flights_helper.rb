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

  def self.airline_stats(flights)
    flights
      .group_by { |f| f[:airline_id] }
      .map do |k,v|
        {
          airline: v.first.airline,
          flights: v.length,
          last_used: v.map(&:depart_date).max
        }
      end
      .sort_by { |x| [x[:flights], x[:last_used]] }
      .reverse
  end

  def self.generate_statistics(flights, limit = 10)
    # create a list of unique flight routes
    # for the purpose of creating a map, we have no use for return routes
    # by that I mean there's no need for CPH-SIN and SIN-CPH.
    # easy way to create a unique path, sort by airport, then unique them
    routes = flights
        .reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .reject { |e| !e.depart_airport_info.has_coordinates? || !e.arrive_airport_info.has_coordinates? }
        .map do |f|
          info = [f.depart_airport_info, f.arrive_airport_info].sort
          { from: info[0], to: info[1] }
        end.uniq

    countries = flights.reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .map { |f| [f.depart_airport_info, f.arrive_airport_info] }
        .flatten
        .map { |a| a.country }

    airports = flights
        .reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .map { |f| [f.depart_airport_info, f.arrive_airport_info] }
        .flatten

    top_airports = airports
        .group_by { |f| f }
        .map { |k,v| { airport: k, flights: v.length } }
        .sort_by { |x| x[:flights] }
        .reverse

    top_countries = countries
        .group_by { |c| c }
        .map { |k,v| { country: Country[k], flights: v.length} }
        .sort_by { |x| x[:flights] }
        .reverse

    top_airlines = airline_stats(flights)

    {
      routes: routes,
      airports: airports.uniq,

      totals: {
        flights: flights.length,
        distance: flights.pluck(:distance).sum,
        duration: flights.pluck(:duration).sum,
        countries: top_countries.length,
        airports: top_airports.length,
        airlines: top_airlines.length
      },
      top_countries: top_countries.take(10),
      top_airports: top_airports.take(10),
      top_airlines: top_airlines.take(10)
    }
  end

end
