json.array!(@airports) do |airport|
  json.extract! airport, :iata_code, :name, :city, :country, :latitude, :longitude, :timezone, :description
end
