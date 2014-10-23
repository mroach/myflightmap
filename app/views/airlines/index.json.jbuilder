json.array!(@airlines) do |airline|
  json.extract! airline, :id, :iata_code, :icao_code, :name, :country
  json.url airline_url(airline, format: :json)
end
