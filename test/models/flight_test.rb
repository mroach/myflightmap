require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  test "setting a known airline_name should set airline_id" do
    airline = airlines(:sq)
    flight = Flight.new(airline_name: airline.name)
    assert_equal airline.id, flight.airline_id
  end

  test "setting airline_id to an iata code should set proper airline_id and airline_name" do
    airline = airlines(:sq)
    flight = Flight.new(airline_id: airline.iata_code)
    assert_equal airline.id, flight.airline_id
    assert_equal airline.name, flight.airline_name
  end

  test "flight_code should be sanitised" do
    flight = Flight.new(flight_code: 'sq 52')
    assert_equal 'SQ52', flight.flight_code
    assert_equal 'SQ', flight.airline_code
    assert_equal '52', flight.flight_number
  end
end
