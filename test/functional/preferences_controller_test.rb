require File.dirname(__FILE__) + '/../test_helper'

class PreferencesControllerTest < ActionController::TestCase
  fixtures :workouts
  
  def setup
    @controller = PreferencesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  def test_index_without_session
    get :index
    assert_redirected_to :controller => 'user', :action => 'signin'
  end
  
  def test_index
    @request.session[:user] = 1
    get :index
    assert_response :success
    assert assigns['user']
  end
  
  def test_save
    @request.session[:user] = 1
    post :index, {:preferences => {:display_name => "andrew", :email => "", :parse_srm_comment => false, :view_type => "index", :sort_order => "name" }}
    assert_response :success
    user = assigns['user']
    assert user
    assert_equal 'andrew', user.preferences[:display_name]
    assert_equal '', user.preferences[:email]
    assert_equal false, user.preferences[:parse_srm_comment]
    assert_equal 'index',user.preferences[:view_type]
    assert_equal 'name', user.preferences[:sort_order]
    assert_tag :tag => 'input', :attributes => {:id => 'preferences[display_name]', :value => 'andrew'} 
  end
  
end
