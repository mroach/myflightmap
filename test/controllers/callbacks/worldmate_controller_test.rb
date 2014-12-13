require 'test_helper'

class Callbacks::WorldmateControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # Load the sample XML response which includes:
  # * A response of SUCCESS
  # * User of XXX000@trips.myflightmap.com - So make sure that exists in user fixtures (user.id_hash)
  # * Three flights
  # * Subject of "My Awesome Trip!"
  setup do
    @xml_file_path = "#{Rails.root}/test/fixtures/files/worldmate_response_sample.xml"
    @xml_string = File.open(@xml_file_path, "r") { |f| f.read }
    @sample_data_flights = 3
  end

  # The controller is responsible for creating the CallbackLog record. Just one.
  test "should create callback_logs entry" do
    assert_difference('CallbackLog.count', 1) do
      post :receive, @xml_string, 'CONTENT_TYPE' => 'text/xml'
    end
    assert_response :success
    assert_response_equals 'SUCCESS'
  end

  test "should create trips and flights" do
    # There will only ever be one trip created by an email import, but the number
    # of flights will depend on the email, so pull that from the value set in
    # the setup method
    assert_differences([['Trip.count', 1], ['Flight.count', @sample_data_flights]]) do
      post :receive, @xml_string, 'CONTENT_TYPE' => 'text/xml'
    end
    assert_response :success
    assert_response_equals 'SUCCESS'
  end
end
