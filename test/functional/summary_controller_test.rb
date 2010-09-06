require 'test_helper'

class SummaryControllerTest < ActionController::TestCase
  fixtures :users
  
  test "index without session" do
    get :show
    assert_redirected_to signin_path
  end
  
  test "index" do
    session[:user] = users(:andrew).id
    get :show
    assert_response :success
    assert assigns['monthly']
    assert assigns['weekly']
  end
end
