require 'test_helper'

class UserControllerTest < ActionController::TestCase
  fixtures :users
  
  test "signup" do
    post(:signup, :user => {:username => 'zabriskie', :email => 'dznuts@gmail.com', :password => 'test', :password_confirmation => 'test', :terms_of_service => 1})
    assert_response :redirect
    assert_redirected_to(:action => 'signin')
    assert_equal 'Thanks for signing up, please signin now.', flash[:notice]
  end

  test "signin" do
    signin 'andrew', 'test'
    assert_response :redirect
    assert_not_nil session[:user]
    assert 'andrew', User.find(session[:user]).username
    assert_equal 'login success', flash[:notice]
  end
  
  test "invalid signin" do
    signin 'andrew', 'test12'
    assert_response :success
    assert_equal 'Username or Password Invalid', flash[:notice]
  end
   
  test "change password" do
    session[:user] = users(:andrew).id
    post(:change_password, :user => {:old_password => 'test', :password => 'blah', :password_confirmation => 'blah' })
    assert_response :redirect
    assert_nil session[:user]
    assert_equal 'Password changed, please signin.', flash[:notice]
  end
  
  test "invalid change password" do
    session[:user] = users(:andrew).id
    post :change_password, :user => {:old_password => 'asdf', :password => 'blah', :password_confirmation => 'blah' }
    assert_equal 'Old Password Incorrect', flash[:notice]
  end
   
  test "signout" do
   session[:user] = users(:andrew).id
   post :signout
   assert_response :redirect
  end
  
  def signin(username, password)
    post :signin, :user => {:username => username, :password => password}
  end

end
