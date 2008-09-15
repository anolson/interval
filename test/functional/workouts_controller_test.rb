require File.dirname(__FILE__) + '/../test_helper'
require 'workouts_controller'
require 'user_controller'

# Re-raise errors caught by the controller.
class WorkoutsController; def rescue_action(e) raise e end; end

class WorkoutsControllerTest < Test::Unit::TestCase
  fixtures :users, :workouts
  
  def setup
    @controller = WorkoutsController.new
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
    assert assigns['workouts']
  end
  
  def test_new
    @request.session[:user] = 1
    get :new
    assert_response :success
  end
  
  def test_create
    @request.session[:user] = 1
    post :create, {:workout => {:name => "Endurance Ride", :notes => "Big Miles", :performed_on => Time.now}, :marker => {:minute => '30', :hour => '1'}}
    assert_response :redirect
  end
  
  def test_create_error
    @request.session[:user] = 1
    post :create, {:workout => {:name => "RR", :notes => "Big Miles", :performed_on => Time.now}, :marker => {:minute => '30', :hour => '1'}}
    assert_response :success
    assert_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
  end
  
  def test_upload_file
    @request.session[:user] = 1
    file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
    post :upload_file, {:training_file => {:payload => file}, :workout => {:name => 'Sprints', :notes => 'Some Sprints'} }
    assert_response :redirect
  end
  
end
