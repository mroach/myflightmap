namespace :data do
  namespace :cleanup do

    task :all => [
      :set_missing_arrive_date,
      :groom_flight_code,
      :standardise_airline_names,
      :set_missing_flight_airline,
      :set_missing_airline_name,
      :refresh_flight_utc_times,
      :refresh_trip_dates,
      :prepend_airline_code,
      :recalculate_flight_distances,
      :estimate_flight_durations
    ]

    # desc "When flight numbers are missing the airline code, add it"
    # task :prepend_airline_code => :environment do
    #   Flights.where("airline_name is not null and flight_code is not null")
    # end

    desc "Set missing arrival date"
    task :set_missing_arrive_date => :environment do
      Flight.where(arrive_date: nil).update_all('arrive_date = depart_date')
    end

    desc "Set missing flight.airline_id when the airline is known by name or code"
    task :set_missing_flight_airline => :environment do
      names = Flight.where("airline_id IS NULL AND airline_name IS NOT NULL AND airline_name != ''")
                    .pluck(:airline_name).sort.uniq
      names.each do |name|
        a = Airline.where("LOWER(name) = ?", name.downcase).first
        if a.nil?
          puts "Couldn't find an airline record for '#{name}'"
        else
          puts "Setting airline to '#{a.iata_code}' for '#{name}' records."
          Flight.where("airline_id IS NULL AND LOWER(airline_name) = ?", name.downcase).each do |f|
            f.airline = a
            f.audit_comment = "Updated by data:cleanup:set_missing_flight_airline"
            f.save!
          end
        end
      end
    end

    desc "Copy airline name into Flight.airline_name"
    task :set_missing_airline_name => :environment do
      Flight.where("airline_name IS NULL AND airline_id IS NOT NULL").each do |f|
        puts "Setting airline name to #{f.airline.name}"
        f.airline_name = f.airline.name
        f.audit_comment = "Updated by data:cleanup:set_missing_airline_name"
        f.save!
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
        "Thai Airways" => "Thai Airways International",
        "United" => "United Airlines",
        "Qantas Airways" => "Qantas",
        "Jetstar" => "Jetstar Airways",
        "Cathay" => "Cathay Pacific",
        "Skyeurope airlines" => "SkyEurope",
        "Ryan Air" => "Ryanair",
        "Virgin Blue" => "Virgin Australia",
        "Norwegian" => "Norwegian Air Shuttle"
      }
      fixes.each do |wrong,right|
        Flight.where("LOWER(airline_name) = ?", wrong.downcase).each do |f|
          f.airline_name = right
          f.audit_comment = "Updated by data:cleanup:standardise_airline_names"
          f.save!
        end
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
          f.audit_comment = "Updated by data:cleanup:groom_flight_code"
          f.save!
        end
      end
    end

    desc "Prepend airline code to flight number"
    task :prepend_airline_code => :environment do
      flights = Flight.where("airline_id IS NOT NULL AND flight_code IS NOT NULL")
      flights.each do |f|
        unless f.flight_code_has_airline_code?
          f.flight_code = "#{f.airline.iata_code}#{f.flight_code}"
          f.audit_comment = "Updated by data:cleanup:prepend_airline_code"
          f.save!
          puts "#{f.depart_airport} => #{f.arrive_airport} FN: #{f.flight_code}"
        end
      end
    end

    desc "Set alliance on airlines"
    task :set_airline_alliances => :environment do
      alliances = {
        :staralliance => %w(JP A3 AC AI NZ NH OZ OS AV SN CM OU MS ET BR LO LH SK ZH SQ SA LX TP TG TK UA),
        :oneworld => %w(AB CX JL MH RJ AA AY LA QF S7 BA IB JJ QR UL),
        :skyteam => %w(SU AR AF AM UX CI MU CZ OK DL GA KQ KL KE ME SV RO VN MF)
      }
      alliances.each do |k,v|
        Airline.where("iata_code IN (?) AND alliance <> ?", v, k).each do |a|
          a.alliance = k
          a.audit_comment = "Updated by data:cleanup:set_airline_alliances"
        end
      end
    end

    desc "Refresh trip begin/end dates"
    task :refresh_trip_dates => :environment do
      Trip.all.each { |e| e.refresh_dates! }
    end

    desc "Refresh flight UTC times"
    task :refresh_flight_utc_times => :environment do
      Flight.all.each do |e|
        if e.depart_airport_info
          depart_utc = TZInfo::Timezone.get(e.depart_airport_info.timezone).local_to_utc(e.depart_date_time)
          e.depart_time_utc = depart_utc
        end

        if e.arrive_airport_info
          arrive_utc = TZInfo::Timezone.get(e.arrive_airport_info.timezone).local_to_utc(e.arrive_date_time)
          e.arrive_time_utc = arrive_utc
        end

        e.audit_comment = "Updated by data:cleanup:refresh_flight_utc_times"
        e.save!
      end
    end

    desc "Regenerate flight slugs"
    task :regenerate_flight_slugs => :environment do
      Flight.all.each do |e|
        e.slug = nil
        e.audit_comment = "Updated by data:cleanup:regenerate_flight_slugs"
        e.save!
      end
    end

    desc "Re-calculate distance on flights"
    task :recalculate_flight_distances => :environment do
      Flight.where("depart_airport IS NOT NULL and arrive_airport IS NOT NULL").each do |f|

        next if f.depart_airport_info.blank? || f.arrive_airport_info.blank?

        distance = Geo.distance_between(
          f.depart_airport_info.coordinates,
          f.arrive_airport_info.coordinates
        ).to_i

        if distance != f.distance
          puts "Updating #{f} distance. #{f.distance} => #{distance}"
          f.distance = distance
          f.audit_comment = "Re-calcualted distance"
          f.save!
        end
      end
    end

    # Estimate the duration on flights when one of the following is true
    # 1) Duration is blank
    # 2) Duration is negative
    # 3) Depart AND Arrive time are 2000-01-01 00:00 (essentially a blank)
    # 4) Depart OR Arrive time are
    desc "Estimate flight durations"
    task :estimate_flight_durations => :environment do
      blank_time = Time.utc(2000, 1, 1, 0, 0, 0)
      Flight.where("
        (depart_airport IS NOT NULL AND arrive_airport IS NOT NULL)
        AND (
          duration IS NULL
          OR duration < 0
          OR depart_time IS NULL
          OR arrive_time IS NULL
          OR (depart_time = ? AND arrive_time = ?)
        )",
        blank_time, blank_time).each do |f|

        from = f.depart_airport_info
        to = f.arrive_airport_info

        next if from.blank? || to.blank?

        duration = DurationEstimator.new.estimate(from.coordinates, to.coordinates)

        # After correcting durations they will still appear in our query if
        # the depart and arrive time are still null
        if f.duration != duration
          puts "Updating #{f.user}'s #{f} duration from #{f.duration} to #{duration}"

          f.duration = duration
          f.audit_comment = "Estimate duration"
          f.save!
        end

      end
    end

  end
end
