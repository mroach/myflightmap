json.array!(@airlines) do |airline|
  json.extract! airline, :id, :iata_code, :name, :country
  json.url airline_url(airline, format: :json)
end
