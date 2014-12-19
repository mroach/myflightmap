require 'test_helper'

class FlightsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flight = flights(:one)
  end

  test "should get index" do
    get :index, username: 'mroach'
    assert_response :success
    assert_not_nil assigns(:flights)
  end

  test "should get new" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    get :new, { username: users(:one).username }
    assert_response :success
  end

  test "should create flight" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    assert_difference('Flight.count') do
      post :create, username: users(:one).username, flight: {
        aircraft_name: @flight.aircraft_name,
        airline_name: @flight.airline_name,
        airline_id: @flight.airline_id,
        arrive_airport: @flight.arrive_airport,
        arrive_date: @flight.arrive_date,
        arrive_time: @flight.arrive_time,
        depart_airport: @flight.depart_airport,
        depart_date: @flight.depart_date,
        depart_time: @flight.depart_time,
        distance: @flight.distance,
        duration: @flight.duration,
        flight_code: @flight.flight_code,
        seat: @flight.seat,
        seat_class: @flight.seat_class,
        seat_location: @flight.seat_location,
        trip_id: @flight.trip_id,
        user_id: @flight.user_id
      }
    end

    assert_redirected_to flight_path(assigns(:flight))
  end

  test "should show flight" do
    get :show, username: users(:one).username, id: @flight
    assert_response :success
  end

  test "should get edit" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    get :edit, username: users(:one).username, id: @flight
    assert_response :success
  end

  test "should update flight" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    patch :update, username: users(:one).username, id: @flight, flight: {
      aircraft_name: @flight.aircraft_name,
      airline_name: @flight.airline_name,
      airline_id: @flight.airline_id,
      arrive_airport: @flight.arrive_airport,
      arrive_date: @flight.arrive_date,
      arrive_time: @flight.arrive_time,
      depart_airport: @flight.depart_airport,
      depart_date: @flight.depart_date,
      depart_time: @flight.depart_time,
      distance: @flight.distance,
      duration: @flight.duration,
      flight_code: @flight.flight_code,
      seat: @flight.seat,
      seat_class: @flight.seat_class,
      seat_location: @flight.seat_location,
      trip_id: @flight.trip_id,
      user_id: @flight.user_id
    }
    assert_redirected_to flight_path(assigns(:flight))
  end

  test "should destroy flight" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    assert_difference('Flight.count', -1) do
      delete :destroy, username: users(:one).username, id: @flight
    end

    assert_redirected_to flights_path
  end
end
