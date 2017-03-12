require 'csv'

namespace :import do
  namespace :v1 do

    desc "Imports users, trips, and flights from a flat CSV file"
    task :flat_file => :environment do

      users = {}
      trips = {}
      flights = {}

      CSV.foreach("tmp/mfmdata.csv") do |row|

        # Add user
        user_id = val(row, :user_id).to_i
        unless users.has_key?(user_id)
          username = val(row, :username)
          if username.blank?
            username = val(row, :email).match(/\A[^@]+/).to_s
          end
          users[user_id] = User.new(
            id: user_id,
            username: username,
            password: val(row, :password),
            email: val(row, :email),
            created_at: val(row, :joined_at),
            audit_comment: "Imported from v1 User##{user_id}"
          )
        end

        # Add trip
        trip_id = val(row, :trip_id).to_i
        unless users.has_key?(trip_id)
          purpose = val(row, :trip_purpose)
          trips[trip_id] = Trip.new(
            id: trip_id + 100,
            user_id: val(row, :user_id),
            name: val(row, :trip_name),
            purpose: (purpose and purpose.capitalize),
            audit_comment: "Imported from v1 Trip##{trip_id}"
          )
        end

        # Add flight
        flight_id = val(row, :flight_id).to_i
        unless users.has_key?(flight_id)

          trip_id = val(row, :trip_id).to_i
          trip_id += 100 if trip_id.present? && trip_id > 0
          airline_code = val(row, :airline_code)

          if airline_code.present?
            airline = Airline.find_by_iata_code(airline_code)
          end

          class_map = {
            'economy' => 'Economy',
            'premium_economy' => 'Economy Plus',
            'business' => 'Business',
            'first' => 'First',
            'suites' => 'Suites'
          }
          seat_location = val(row, :seat_location)

          depart_date = val(row, :depart_date, '1900-01-01')
          depart_date = '1900-01-01' if depart_date == '0000-00-00'
          depart_date.sub!(/^(\d{4}-)00/, '\101')
          depart_date.sub!(/^(\d{4}-\d{2}-)00/, '\101')

          flights[flight_id] = Flight.new(
            id: flight_id + 1000,
            user_id: val(row, :user_id),
            trip_id: trip_id,
            airline: airline,
            flight_code: val(row, :flight_number),
            depart_airport: val(row, :depart_airport),
            depart_date: depart_date,
            depart_time: val(row, :depart_time),
            arrive_airport: val(row, :arrive_airport),
            arrive_date: val(row, :arrive_date),
            arrive_time: val(row, :arrive_time),
            distance: val(row, :distance),
            duration: val(row, :duration).to_i,
            seat: val(row, :seat),
            seat_class: class_map[val(row, :seat_class)],
            seat_location: (seat_location and seat_location.capitalize),
            airline_name: val(row, :airline_name),
            #aircraft_name: val(row, :aircraft_name),
            aircraft_type: val(row, :aircraft_name),
            #aircraft_registration: val(row, :aircraft_registration),
            audit_comment: "Imported from v1 Flight##{flight_id}"
          )
        end
      end

      flights.reject! { |k,v| v.arrive_airport.blank? }

      puts "Users: #{users.length}"
      puts "Trips: #{trips.length}"
      puts "Flights: #{flights.length}"
      #users.each { |e| puts e.inspect }
      # flights.each do |k,v|
      #   if v.depart_date.nil?
      #     puts v.inspect
      #   end
      # end
      ActiveRecord::Base.transaction do
        puts "Saving users"
        users.each { |k,v| v.save! }

        puts "Saving trips"
        trips.each { |k,v| v.save! }

        puts "Saving flights"
        flights.each do |k,v|
          puts "Saving flight #{k} (#{v.depart_airport} - #{v.arrive_airport})"
          v.save!
        end
      end

    end

    def val(row, field, fallback = nil)
      fields = %w(
        user_id
        username
        email
        joined_at
        password

        flight_id
        flight_number
        depart_airport
        depart_date
        depart_time
        arrive_airport
        arrive_date
        arrive_time
        distance
        duration
        seat
        seat_class
        seat_location
        airline_code
        airline_name

        trip_id
        trip_name
        trip_purpose

        aircraft_id
        aircraft_name
        aircraft_abbreviation
        aircraft_manufacturer
        aircraft_type
        aircraft_country
        aircraft_class
      )
      field_hash = Hash[fields.map.with_index.to_a].symbolize_keys
      begin
        val = row[field_hash[field]]
      rescue
        puts "Failed to find a value for field '#{field}'"
      end

      val = nil if val == '\N'

      val.blank? ? fallback : val
    end
  end
end
