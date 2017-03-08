require 'test_helper'

class Callbacks::WorldmateControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # Load the sample XML responses into a hash
  #
  # SUCCESS:
  # * A response of SUCCESS
  # * User of XXX000@trips.myflightmap.com - So make sure that exists in user fixtures (user.id_hash)
  # * Three flights
  # * Subject of "My Awesome Trip!"
  #
  # UNRECOGNIZED_FORMAT:
  # * User of XXX000@trips.myflightmap.com - So make sure that exists in user fixtures (user.id_hash)
  # * No flights
  setup do
    available_types = %w(success unrecognized_format)
    # Create a hash like:
    # {
    #    success: "<xml...>",
    #    unrecognized_format: "<xml...>",
    # }
    @xml_samples = Hash[available_types.map { |k| [k.to_sym, load_file(k)] }]
    @sample_data_flights = 3
  end

  # The controller is responsible for creating the CallbackLog record. Just one.
  test 'should create callback_logs entry' do
    assert_difference('CallbackLog.count', 1) do
      post :receive, @xml_samples[:success], 'CONTENT_TYPE' => 'text/xml'
    end
    assert_response :success
    assert_response_equals 'SUCCESS'
  end

  test 'should create trips and flights' do
    # There will only ever be one trip created by an email import, but the number
    # of flights will depend on the email, so pull that from the value set in
    # the setup method
    assert_differences([['Trip.count', 1], ['Flight.count', @sample_data_flights]]) do
      post :receive, @xml_samples[:success], 'CONTENT_TYPE' => 'text/xml'
    end
    assert_response :success
    assert_response_equals 'SUCCESS'
  end

  test 'should respond with failure status' do
    post :receive, @xml_samples[:unrecognized_format], 'CONTENT_TYPE' => 'text/xml'
    assert_response :success
    assert_response_equals 'UNRECOGNIZED_FORMAT'
  end

  test 'should log failed attempt to parse and include user id' do
    assert_difference('CallbackLog.count', 1) do
      post :receive, @xml_samples[:unrecognized_format], 'CONTENT_TYPE' => 'text/xml'
    end
    assert_response :success
    assert_response_equals 'UNRECOGNIZED_FORMAT'
    assert_equal '1', CallbackLog.all.first.target_id
  end

  private

  def load_file(type)
    path = "#{Rails.root}/test/fixtures/files/worldmate_response_#{type}.xml"
    File.open(path, 'r', &:read)
  end
end
