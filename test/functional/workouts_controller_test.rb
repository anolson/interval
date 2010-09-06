require 'test_helper'

class WorkoutsControllerTest < ActionController::TestCase
  fixtures :users, :workouts, :markers
  
  test "index without session" do
    get :index
    assert_redirected_to signin_path
  end
  
  test "index" do
    session[:user] = users(:andrew).id  
    get :index
    assert_response :success
    assert assigns['workouts']
  end
  
  test "new" do
    session[:user] = users(:andrew).id
    get :new
    assert_response :success
  end
  
  test "create" do
    session[:user] = users(:andrew).id
    post :create, {:workout => {:name => "Endurance Ride", :notes => "Big Miles", :performed_on => Time.now}, :marker => {:minute => '30', :hour => '1'}}
    assert_response :redirect
  end
  
  test "show" do
    session[:user] = users(:andrew).id
    post :show, {:id => 1}
    assert_response :success
    
  end
  
  test "edit" do
    session[:user] = users(:andrew).id
    get :edit, {:id => 1}
    assert_response :success
    assert assigns(:workout)
  end
  
  test "update" do
    put(:update, {:id => 1, :workout => { :name => "Easy RR ride." }, :marker => {:hour => "1", :minute => "0", :second => "0"}}, :user => users(:andrew).id)
    assert_response :success
    assert_select_rjs :replace_html, "workout_name"
  end

end
