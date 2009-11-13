require File.dirname(__FILE__) + '/../test_helper'

class TrainingFilesControllerTest < ActionController::TestCase
  
  fixtures :users, :plans, :subscriptions
  
  def setup
    @controller = TrainingFilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # Replace this with your real tests.
  def test_create
    @request.session[:user] = 1
    file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
    post :create, {:workout => {:name => 'Sprints', :notes => 'Some Sprints', :training_files_attributes => [{:payload => file}]}}
    assert_response :redirect
  end
end
