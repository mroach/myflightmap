json.array!(@airlines) do |airline|
  json.extract! airline, :iata_code, :name, :country
end
