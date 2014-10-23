json.array!(@flights) do |flight|
  json.extract! flight, :id, :user_id, :trip_id, :number, :depart_airport_id, :depart_date, :depart_time, :arrive_airport_id, :arrive_date, :arrive_time, :distance, :duration, :airline_id, :airine_name, :aircraft_name, :seat, :seat_class, :seat_location
  json.url flight_url(flight, format: :json)
end
