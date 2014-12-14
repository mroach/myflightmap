require 'httparty'

module TZUtils
  class Lookup
    def self.google(lat, lon)
      query = { location: "#{lat},#{lon}", timestamp: "1331161200", key: Rails.application.secrets.google }
      response = HTTParty.get("https://maps.googleapis.com/maps/api/timezone/json", query: query)
      response["timeZoneId"]
    end

    def self.timezonedb(lat, lon)
      query = { lat: lat, lng: lon, format: :json, key: Rails.application.secrets.timezonedb }
      response = HTTParty.get("http://api.timezonedb.com/", query: query)
      response['zoneName']
    end

    def self.try_all(lat, lon)
      self.google(lat, lon) || self.timezonedb(lat, lon)
    end
  end
end
