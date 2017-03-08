require 'test_helper'

class AirlinesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should deny index to anonymous' do
    get :index
    assert_response :redirect
  end

  test 'should allow json index to logged-in' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:two)

    get :index, { format: 'json' }
    assert_response :success
  end

  test 'should show for logged-in' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:two)

    get :show, { id: 'SQ' }
    assert_response :success
  end
end
