require 'test_helper'

class FlightsControllerTest < ActionController::TestCase
  setup do
    @flight = flights(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flights)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flight" do
    assert_difference('Flight.count') do
      post :create, flight: { aircraft_name: @flight.aircraft_name, airine_name: @flight.airine_name, airline_id: @flight.airline_id, arrive_airport_id: @flight.arrive_airport_id, arrive_date: @flight.arrive_date, arrive_time: @flight.arrive_time, depart_airport_id: @flight.depart_airport_id, depart_date: @flight.depart_date, depart_time: @flight.depart_time, distance: @flight.distance, duration: @flight.duration, number: @flight.number, seat: @flight.seat, seat_class: @flight.seat_class, seat_location: @flight.seat_location, trip_id: @flight.trip_id, user_id: @flight.user_id }
    end

    assert_redirected_to flight_path(assigns(:flight))
  end

  test "should show flight" do
    get :show, id: @flight
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flight
    assert_response :success
  end

  test "should update flight" do
    patch :update, id: @flight, flight: { aircraft_name: @flight.aircraft_name, airine_name: @flight.airine_name, airline_id: @flight.airline_id, arrive_airport_id: @flight.arrive_airport_id, arrive_date: @flight.arrive_date, arrive_time: @flight.arrive_time, depart_airport_id: @flight.depart_airport_id, depart_date: @flight.depart_date, depart_time: @flight.depart_time, distance: @flight.distance, duration: @flight.duration, number: @flight.number, seat: @flight.seat, seat_class: @flight.seat_class, seat_location: @flight.seat_location, trip_id: @flight.trip_id, user_id: @flight.user_id }
    assert_redirected_to flight_path(assigns(:flight))
  end

  test "should destroy flight" do
    assert_difference('Flight.count', -1) do
      delete :destroy, id: @flight
    end

    assert_redirected_to flights_path
  end
end
