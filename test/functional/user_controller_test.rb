require 'test_helper'

class UserControllerTest < ActionController::TestCase
  fixtures :users
  
  test "signup" do
    post(:signup, :user => {:username => 'zabriskie', :email => 'dznuts@gmail.com', :password => 'test', :password_confirmation => 'test', :terms_of_service => 1})
    assert_response :redirect
    assert_redirected_to(:action => 'signin')
    assert_equal 'Thanks for signing up, please signin now.', flash[:notice]
  end

end
