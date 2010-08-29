require 'test_helper'

class PasswordChangeControllerTest < ActionController::TestCase  
  fixtures :users
  
  test "change password" do
    session[:user] = users(:andrew).id
    post(:create, :user => {:current_password => 'test', :password => 'blah', :password_confirmation => 'blah' })
    assert_response :redirect
    assert_nil session[:user]
    assert_equal 'Password changed, please signin.', flash[:notice]
  end
  
  test "invalid change password" do
    session[:user] = users(:andrew).id
    post :create, :user => {:current_password => 'asdf', :password => 'blah', :password_confirmation => 'blah' }
    assert_equal 'Old Password Incorrect', flash[:notice]
    assert_response :redirect
  end
end
