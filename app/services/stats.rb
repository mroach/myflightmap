class Stats
  # create a list of unique flight routes
  # for the purpose of creating a map, we have no use for return routes
  # by that I mean there's no need for CPH-SIN and SIN-CPH.
  # easy way to create a unique path, sort by airport, then unique them
  def self.from_flights(flights)
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

    airlines = flights.map { |e| e.airline }

    top_airports = airports
                   .group_by { |f| f }
                   .map { |k, v| { airport: k, flights: v.length } }
                   .sort_by { |x| x[:flights] }
                   .reverse

    top_countries = countries
                    .group_by { |c| c }
                    .map { |k, v| { country: Country[k], flights: v.length } }
                    .sort_by { |x| x[:flights] }
                    .reverse

    top_airlines = airlines
                   .group_by { |a| a }
                   .map { |k, v| { airline: k, flights: v.length } }
                   .sort_by { |x| x[:flights] }
                   .reverse

    {
      routes:        routes,
      airports:      airports.uniq,

      totals:        {
        flights:   flights.length,
        distance:  flights.pluck(:distance).compact.sum,
        duration:  flights.pluck(:duration).compact.sum,
        countries: top_countries.length,
        airports:  top_airports.length,
        airlines:  top_airlines.length
      },
      top_countries: top_countries,
      top_airports:  top_airports,
      top_airlines:  top_airlines
    }
  end
end
