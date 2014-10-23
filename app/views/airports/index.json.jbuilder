json.array!(@airports) do |airport|
  json.extract! airport, :id, :iata_code, :icao_code, :name, :city, :country, :latitude, :longitude, :timezone, :description
  json.url airport_url(airport, format: :json)
end
