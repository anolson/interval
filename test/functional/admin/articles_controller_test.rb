require 'test_helper'

class Admin::ArticlesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_articles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create articles" do
    assert_difference('Admin::Articles.count') do
      post :create, :articles => { }
    end

    assert_redirected_to articles_path(assigns(:articles))
  end

  test "should show articles" do
    get :show, :id => admin_articles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_articles(:one).id
    assert_response :success
  end

  test "should update articles" do
    put :update, :id => admin_articles(:one).id, :articles => { }
    assert_redirected_to articles_path(assigns(:articles))
  end

  test "should destroy articles" do
    assert_difference('Admin::Articles.count', -1) do
      delete :destroy, :id => admin_articles(:one).id
    end

    assert_redirected_to admin_articles_path
  end
end
