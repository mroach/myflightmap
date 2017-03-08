require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "admin user: index: should get index" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:one)

    get :index
    assert_response :success
  end

  test "standard user: index: should get bounced away" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:two)

    get :index
    assert_response :redirect
  end

  test "no user: index: should get bounced away" do
    get :index
    assert_response :redirect
  end

  test "standard user: show show profile" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users(:two)

    get :show, { username: 'mroach' }
    assert_response :success
  end

  test "non user: show show profile" do
    get :show, { username: 'mroach' }
    assert_response :success
  end
end
