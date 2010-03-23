require 'test_helper'

class PreferencesControllerTest < ActionController::TestCase
  fixtures :users
    
  test "index without session" do
    get :index
    assert_redirected_to :controller => 'user', :action => 'signin'
  end
  
  test "index" do
    @request.session[:user] = users(:andrew).id
    get :index
    assert_response :success
    assert assigns['user']
  end
  
  test "save" do
    session[:user] = users(:andrew).id
    post :index, {:preferences => {:display_name => "andrew", :email => "", :parse_srm_comment => false, :view_type => "index", :sort_order => "name" }}
    assert_response :success
    user = assigns['user']
    assert user
    assert_equal 'andrew', user.preferences[:display_name]
    assert_equal '', user.preferences[:email]
    assert_equal false, user.preferences[:parse_srm_comment]
    assert_equal 'index',user.preferences[:view_type]
    assert_equal 'name', user.preferences[:sort_order]
  end
  
end
