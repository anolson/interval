require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_signup_for_free_plan
    @request.env['HTTPS'] = 'on'

    post :signup, :user => {:username => 'zabriskie', :email => 'dznuts@gmail.com', :password => 'test', :password_confirmation => 'test', :terms_of_service => 1}, :plan => 'free'
    assert_response :redirect
    assert_redirected_to( :action => 'signin' )
    


  end
  
=begin
  def test_signin
    signin 'andrew', 'test'
  end
  
  def test_invalid_signin
    post :signin, :user => {:username => 'andrew', :password => 'test12'}
    assert_response :success
    assert_equal 'Username or Password Invalid', flash[:notice]
  end
  
  def test_change_password
    signin 'andrew', 'test'
    post :change_password, :user => {:old_password => 'test', :password => 'blah', :password_confirmation => 'blah' }
    assert_response :redirect
    assert_nil session[:user]
    assert_equal 'Password changed, please signin.', flash[:notice]
  end
  
  def test_invalid_change_password
    signin 'andrew', 'test'
    post :change_password, :user => {:old_password => 'asdf', :password => 'blah', :password_confirmation => 'blah' }
    assert_equal 'Old Password Incorrect', flash[:notice]
  end
  
  def test_signout
    signin 'andrew', 'test'
    post :signout
    assert_response :redirect
  end
=end
end
