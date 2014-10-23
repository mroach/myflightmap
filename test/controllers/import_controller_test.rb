require 'test_helper'

class ImportControllerTest < ActionController::TestCase
  test "should get flight_memory" do
    get :flight_memory
    assert_response :success
  end

end
