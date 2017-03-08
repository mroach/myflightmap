require 'test_helper'

class TripsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @trip = trips(:one)
  end

  test 'should get index' do
    get :index, username: users(:one)
    assert_response :success
    assert_not_nil assigns(:trips)
  end

  test 'should get new' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:one)

    get :new, username: users(:one).username
    assert_response :success
  end

  test 'should create trip' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:one)

    assert_difference('Trip.count') do
      post :create, username: users(:one).username, trip: {
        name: @trip.name, purpose: @trip.purpose, user_id: @trip.user_id }
    end

    assert_redirected_to trip_path(assigns(:trip))
  end

  test 'should show trip' do
    get :show, id: @trip, username: users(:one).username
    assert_response :success, username: users(:one).username
  end

  test 'should get edit' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:one)

    get :edit, id: @trip, username: users(:one).username
    assert_response :success
  end

  test 'should update trip' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:one)

    patch :update, id: @trip, username: users(:one).username, trip: {
      name: @trip.name, purpose: @trip.purpose, user_id: @trip.user_id }
    assert_redirected_to trip_path(assigns(:trip))
  end

  test 'should destroy trip' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:one)

    assert_difference('Trip.count', -1) do
      delete :destroy, id: @trip, username: users(:one).username
    end

    assert_redirected_to trips_path
  end
end
