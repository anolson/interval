require File.dirname(__FILE__) + '/../test_helper'

class SummaryControllerTest < ActionController::TestCase
  fixtures :workouts
  
  def setup
    @controller = SummaryController.new
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
    assert assigns['monthly']
    assert assigns['weekly']
  end
end
