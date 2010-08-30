require 'test_helper'

class UserControllerTest < ActionController::TestCase
  fixtures :users
  
  test "create" do
    post(:create, :user => {:username => 'zabriskie', :email => 'dznuts@gmail.com', :password => 'test', :password_confirmation => 'test', :terms_of_service => 1})
    assert_response :redirect
    assert_redirected_to(signin_path)
    assert_equal 'Thanks for signing up, please signin now.', flash[:notice]
  end
  
  test "create with errors" do
    post(:create, :user => {:username => 'andrew', :email => 'andrew@intervalapp.com', :password => 'test', :password_confirmation => 'test', :terms_of_service => 1})
    assert_response :redirect
    assert_redirected_to(signup_path)
  end

end
