# Downloads airports from https://www.developer.aero/Airport-API

require 'net/http'
require 'uri'
require 'json'
require 'countries'
require 'logging'

KEY = '3f12387b4d323062e72373b75c9f6102'
logger ||= Logger.new(STDOUT)

airport_url = "https://airport.api.aero/airport?user_key=#{KEY}"

puts "Fetching airports from #{airport_url}"

uri = URI.parse(airport_url)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
#http.set_debug_output $stdout

request = Net::HTTP::Get.new(uri.request_uri)
request.add_field("Accept", "application/json")

response = http.request(request)

response_data = JSON.parse(response.read_body)["airports"]

# Remove airports without names
response_data.delete_if do |e|
  if e["name"].nil?
    logger.warn "Skipping nameless airport: #{e}"
    next true
  end
  false
end

# Remove railway stations
response_data.delete_if do |e|
  if e["name"].match(/\bRailway\b/i)
    logger.warn "Skipping railway station: #{e}"
    next true
  end
  false
end

# Countries are return by name rather than ISO code.
# Some names don't match ISO 3166
irregular_country_names = {
  'Burma' => 'MM',
  'Congo (Brazzaville)' => 'CG',
  'Congo (Kinshasa)' => 'CD',
  'Cote d\'Ivoire' => 'CI',
  'Korea' => 'KR',
  'South Korea' => 'KR',
  'North Korea' => 'KP',
  'Macau' => 'MO',
  'Reunion' => 'RE',
  'Virgin Islands' => 'VI'
}

airports = response_data.map do |a|

  # Convert country names into objects. Irregular airports first.
  country_name = a["country"]

  if irregular_country_names.has_key?(country_name)
    country = Country[irregular_country_names[country_name]]
  else
    country = Country.find_country_by_name(country_name)
  end

  logger.warn "Airport #{a['code']} has unknown country '#{country_name}'" if country.nil?

  {
    iata_code: a["code"],
    icao_code: nil,
    name: a["name"],
    city: a["city"],
    country: country.alpha2,
    latitude: a["lat"],
    longitude: a["lng"],
    timezone: a["timezone"],
    description: a["name"]
  }
end.sort_by { |a| a[:iata_code] }

logger.info "Creating #{airports.size} airports"

Airport.create(airports)

logger.info "Done"
