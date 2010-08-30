require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :users
  
  test "signin" do
    signin 'andrew', 'test'
    assert_response :redirect
    assert_not_nil session[:user]
    assert 'andrew', User.find(session[:user]).username
  end
  
  test "invalid signin" do
    signin 'andrew', 'test12'
    assert_equal 'Username or Password Invalid', flash[:notice]
    assert_response :redirect
  end
   
  test "destroy" do
   session[:user] = users(:andrew).id
   post :destroy
   assert_response :redirect
  end
  
  def signin(username, password)
    post :create, :user => {:username => username, :password => password}
  end
end
