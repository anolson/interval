require 'test_helper'

class PreferencesControllerTest < ActionController::TestCase
  fixtures :users
    
  test "index without session" do
    get :show
    assert_redirected_to signin_path
  end
  
  test "index" do
    @request.session[:user] = users(:andrew).id
    get :show
    assert_response :success
    assert assigns['user']
  end
  
  test "save" do
    session[:user] = users(:andrew).id
    post :update, { :user => { :email => "anolson@localhost", :preferences => {:display_name => "andrew", :parse_srm_comment => false, :view_type => "index", :sort_order => "name" } } }
    assert_redirected_to preferences_path
    user = assigns['user']
    assert user
    assert_equal 'andrew', user.preferences[:display_name]
    assert_equal 'anolson@localhost', user.email
    assert_equal false, user.preferences[:parse_srm_comment]
    assert_equal 'index',user.preferences[:view_type]
    assert_equal 'name', user.preferences[:sort_order]
  end
  
end
