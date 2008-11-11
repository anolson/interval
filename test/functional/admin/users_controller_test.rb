require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_users
    assert_difference('Admin::Users.count') do
      post :create, :users => { }
    end

    assert_redirected_to users_path(assigns(:users))
  end

  def test_should_show_users
    get :show, :id => admin_users(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin_users(:one).id
    assert_response :success
  end

  def test_should_update_users
    put :update, :id => admin_users(:one).id, :users => { }
    assert_redirected_to users_path(assigns(:users))
  end

  def test_should_destroy_users
    assert_difference('Admin::Users.count', -1) do
      delete :destroy, :id => admin_users(:one).id
    end

    assert_redirected_to admin_users_path
  end
end
