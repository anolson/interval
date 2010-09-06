require 'test_helper'

class ProcessorsControllerTest < ActionController::TestCase
  fixtures :workouts, :users
  
  test "index" do
    session[:user] = users(:andrew).id  
    get :index, {:format => :js}
    assert_response :success
    assert assigns(:processors)
  end
  
  test "show" do
    get :show, {:id => 6, :format => :js}, :user => users(:andrew).id  
    assert assigns(:workout)
    assert :success
  end

end
