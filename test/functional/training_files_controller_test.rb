require 'test_helper'

class TrainingFilesControllerTest < ActionController::TestCase
  fixtures :users
  
  test "create" do
    session[:user] = users(:andrew).id
    file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
    post :create, {:workout => {:name => 'Sprints', :notes => 'Some Sprints', :training_files_attributes => [{:payload => file}]}}
    assert_response :redirect
  end
  
end
