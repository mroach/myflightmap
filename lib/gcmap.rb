require 'nokogiri'
require 'httparty'

class Gcmap
  include Logging

  def get_airport(iata_code)
    iata_code.upcase!
    # Grab HTML from Great Circle Mapper and scrape out:
    # Latitude
    # Longitude
    # Country
    # City
    # Airport name
    gcmap_url = "http://www.gcmap.com/airport/#{iata_code}"
    logger.debug "Grabbing HTML from #{gcmap_url}"
    gcmap_result = HTTParty.get(gcmap_url)

    if gcmap_result.code != 200
      logger.warn "Failed to lookup '#{iata_code}': #{gcmap_result.message}"
      return nil
    end

    logger.debug "Parsing GCMap result"
    html = Nokogiri::HTML(gcmap_result)
    latlon = html.css('meta[name="geo.position"]').first["content"].split(/;/)
    lat = latlon[0]
    lon = latlon[1]
    country = html.css('meta[name="geo.region"]').first["content"][0..1]
    city = html.css('span.locality').first.text
    name = html.css('td.fn.org').first.text
    description = name.sub(/\s*airport\s*/i, '')

    # Use the Google Time Zone API to figure out what time zone the
    # airport is in based on its coordinates
    query = { location: "#{lat},#{lon}", timestamp: "1331161200", key: Rails.application.secrets.google }
    logger.debug "Finding timezone using Google Timezone API. Params: #{query}"
    google_response = HTTParty.get("https://maps.googleapis.com/maps/api/timezone/json", query: query)
    time_zone = google_response["timeZoneId"]

    data = {
      iata_code: iata_code,
      name: name,
      city: city,
      country: country,
      latitude: lat,
      longitude: lon,
      timezone: time_zone,
      description: description
    }

    Airport.new(data)
  end
end
