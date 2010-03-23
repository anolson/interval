require 'test_helper'

class SummaryControllerTest < ActionController::TestCase
  fixtures :users
  
  test "index without session" do
    get :index
    assert_redirected_to :controller => 'user', :action => 'signin'
  end
  
  test "index" do
    session[:user] = users(:andrew).id
    get :index
    assert_response :success
    assert assigns['monthly']
    assert assigns['weekly']
  end
end
