require 'test_helper'

class ImportControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should deny index to anonymous" do
    get :index
    assert_response :redirect
  end

  test "should allow index to logged-in" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:two)

    get :index
    assert_response :success
  end
end
