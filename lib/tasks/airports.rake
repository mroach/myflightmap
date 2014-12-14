require 'httparty'
require 'csv'
require 'tzutils'

def download_airport_data(url, force_refresh = false)
  file_name = url.scan(/[^\/]+$/).first
  local_path = File.join(Rails.root, 'tmp', file_name)

  # Force a refresh if the file is older than 7 days
  if File.exists?(local_path)
    age = (Time.now - File.stat(local_path).mtime).to_i
    if force_refresh = age > 7.days
      puts "File is #{age / 1.day} days old. Time to refresh."
    else
      puts "File is #{age / 1.day} days old. Ok to keep using"
    end
  end

  if force_refresh || !File.exists?(local_path)
    puts "Downloading #{url} => #{local_path}"
    File.open(local_path, 'wb+') do |f|
      f.write HTTParty.get(url).body
    end
  else
    puts "Using cached copy of #{local_path}"
  end

  local_path
end

IATA_REGEX = /^[A-Z]{3}$/
ICAO_REGEX = /^[A-Z]{4}$/

namespace :airports do

  desc "Downloads latest airport data and imports"
  task :refresh_from_external => :environment do
    csv_file_path = download_airport_data("http://ourairports.com/data/airports.csv")

    airports = {}
    CSV.foreach(csv_file_path, headers: true) do |row|
      code = row['iata_code']
      next unless code and code.match(IATA_REGEX)
      next if row['type'] == 'closed'
      next if row['scheduled_service'] == 'no'

      if airports.key?(code)
        puts "Duplicate detected for #{code}"

        existing = airports[code]

        # It tends to be that the one that has an ICAO code for an 'ident'
        # is the keeper. If they both have an ICAO ident, keep the one with
        # the higher id
        if existing['ident'] =~ ICAO_REGEX && row['ident'] =~ ICAO_REGEX
          keeper = existing['id'].to_i > row['id'].to_i ? existing : row
        elsif existing['ident'] =~ ICAO_REGEX
          keeper = existing
        else
          keeper = row
        end

        airports[code] = keeper
      else
        airports[code] = row
      end
    end

    airports.each do |code,a|
      city = a['municipality']
      # Remove the name 'Airport'. Yes, we know it's an airport.
      name = a['name'].sub(/\s*Airport\s*/i, '')

      # We want the description to contain the city name, so if it doesn't,
      # combine the city with the airport name so you get something like
      # Tokyo Narita, London City, Singapore Changi
      if city && !name.match(Regexp.new(Regexp.escape(city)))
        description = "#{city} #{name}"
      else
        description = name
      end

      # Build a hash of updates
      values = {
        name: name,
        description: description,

        # Round off to 6 decimal places, to match the storage in the database
        # Otherwise you end up with bogus audit entries
        latitude: sprintf('%0.6f', a['latitude_deg'].to_f),
        longitude: sprintf('%0.6f', a['longitude_deg'].to_f),
        country: a['iso_country'],
        city: a['municipality']
      }

      #puts values.inspect

      airport = Airport.find_or_initialize_by(iata_code: code)

      if airport.new_record?
        puts "Airport #{code} is new so we need to get the timezone for it"
        values[:timezone] = TZUtils::Lookup.google(values[:latitude], values[:longitude])
        puts values.inspect
      else
        puts "Airport #{code} already exists. How nice."
      end

      # Remove nils. We don't want to overwrite good data with nils
      values.delete_if { |k,v| v.blank? }

      # Mass-assignment of updated values
      airport.assign_attributes(values)

      # If we made any changes, note that in the audit log comment
      if airport.changed?
        airport.audit_comment = "Data source: OurAirports"
      end

      airport.save!
    end

  end

end
