namespace :data do
  namespace :cleanup do

    task :all => [:groom_flight_code, :standardise_airline_names, :set_missing_flight_airline, :refresh_trip_dates]

    # desc "When flight numbers are missing the airline code, add it"
    # task :prepend_airline_code => :environment do
    #   Flights.where("airline_name is not null and flight_code is not null")
    # end
    desc "Set missing flight.airline_id when the airline is known by name or code"
    task :set_missing_flight_airline => :environment do
      names = Flight.where("airline_id IS NULL AND airline_name IS NOT NULL AND airline_name != ''")
                    .pluck(:airline_name).sort.uniq
      names.each do |name|
        a = Airline.find_by name: name
        if a.nil?
          puts "Couldn't find an airline record for '#{name}'"
        else
          puts "Setting airline to '#{a.iata_code}' for '#{name}' records."
          Flight.where("airline_id IS NULL").where(airline_name: name).update_all(airline_id: a.id)
        end
      end
    end

    desc "Standardise airline names"
    task :standardise_airline_names => :environment do
      fixes = {
        "Air Asia" => "AirAsia",
        "AirTran" => "AirTran Airways",
        "ANA All Nippon Airways" => "All Nippon Airways",
        "CSA Czech Airlines" => "Czech Airlines",
        "Emirates Airlines" => "Emirates",
        "EVA Evergreen Airways" => "EVA Air",
        "Iberia" => "Iberia Airlines",
        "JAL Japan Airlines" => "Japan Airlines",
        "JetBlue" => "JetBlue Airways",
        "Malmo Aviation" => "Malmö Aviation",
        "SAA South African Airways" => "South African Airways",
        "Scandinavian Airlines" => "Scandinavian Airlines System",
        "SAS Scandinavian Airlines" => "Scandinavian Airlines System",
        "SWISS" => "Swiss International Airlines",
        "Swiss International Airlines" => "Swiss International Air Lines",
        "Thai Airways" => "Thai Airways International"
      }
      fixes.each do |wrong,right|
        Flight.where(airline_name: wrong).update_all(airline_name: right)
      end
    end

    desc "Cleanup flight codes"
    task :groom_flight_code => :environment do
      flights = Flight.where("flight_code IS NOT NULL")
      # Flight codes can only contain numbers and letters
      re = /[^A-Z0-9]/
      flights.each do |f|
        if f.flight_code.match(re)
          new_fc = f.flight_code.upcase.sub(re, '')
          puts "Fixing airline code #{f.flight_code} to #{new_fc}"
          f.flight_code = new_fc
          f.save!
        end
      end
    end

    desc "Prepend airline code to flight number"
    task :prepend_airline_code => :environment do
      flights = Flight.where("airline_id IS NOT NULL AND flight_code IS NOT NULL")
      flights.reject!(&:flight_code_has_airline_code?)
      flights.each { |f| f.flight_code = "#{f.airline.iata_code}#{f.flight_code}"; f.save! }
      puts flights.map { |e| "#{e.depart_airport} => #{e.arrive_airport} FN: #{e.flight_code}" }
    end

    desc "Set alliance on airlines"
    task :set_airline_alliances => :environment do
      alliances = {
        :staralliance => %w(JP A3 AC AI NZ NH OZ OS AV SN CM OU MS ET BR LO LH SK ZH SQ SA LX TP TG TK UA),
        :oneworld => %w(AB CX JL MH RJ AA AY LA QF S7 BA IB JJ QR UL),
        :skyteam => %w(SU AR AF AM UX CI MU CZ OK DL GA KQ KL KE ME SV RO VN MF)
      }
      alliances.each { |k,v| Airline.where("iata_code IN (?) AND alliance <> ?", v, k).update_all(alliance: k) }
    end

    desc "Refresh trip begin/end dates"
    task :refresh_trip_dates => :environment do
      Trip.all.each { |e| e.refresh_dates! }
    end

    desc "Refresh flight UTC times"
    task :refresh_flight_utc_times => :environment do
      Flight.all.each do |e|
        depart_utc = TZInfo::Timezone.get(e.depart_airport_info.timezone).local_to_utc(e.depart_date_time)
        e.depart_time_utc = depart_utc

        arrive_utc = TZInfo::Timezone.get(e.arrive_airport_info.timezone).local_to_utc(e.arrive_date_time)
        e.arrive_time_utc = arrive_utc

        e.save!
      end
    end
  end
end
