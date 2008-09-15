require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users
  
  def test_create
    user = User.create({:username => "bob", :password => "whatever", :password_confirmation => "whatever"})
    assert_kind_of User, user
    assert_equal "bob", user.username
    assert_equal "bob", user.preferences["display_name"]
  end
  
  def test_duplicate_username
    user = User.create({:username => "andrew", :password => "whatever", :password_confirmation => "whatever"})
    user.save
    assert user.errors.invalid?(:username)
  end
  
  def test_missing_password_confirmation
    user = User.create({:username => "juli", :password => "whatever"})
    assert user.errors.invalid?(:password_confirmation)
  end
  
  def test_non_matching_password_confirmation
    user = User.create({:username => "juli", :password => "whatever", :password_confirmation => "blah"})
    assert user.errors.invalid?(:password)
  end
  
  def test_authenticate 
    user = User.authenticate("andrew", "test")
    assert_kind_of User, user
    assert "andrew", user.username
  end
  
  def test_authenticate_invalid_username
    assert_raise(RuntimeError) { User.authenticate("ralph", "test") } 
  end
  
  def test_authenticate_invalid_password
    assert_raise(RuntimeError) { User.authenticate("andrew", "testing-1-2-3") } 
  end
  
  def test_change_password
    User.change_password(1, {:old_password => 'test', :password => 'testing', :password_confirmation => 'testing'})
    assert users(:andrew).password_matches?('testing')
  end
  
  def test_change_password_incorrect_old_password
    assert_raise(RuntimeError) {
      User.change_password(1, {:old_password => 'testing', :password => 'testing', :password_confirmation => 'testing'})
    }
  end
  
  def test_change_password_non_matching_password_confirmation
    assert_raise(ActiveRecord::RecordInvalid) {
      User.change_password(1, {:old_password => 'test', :password => 'testing', :password_confirmation => 'testing123'})
    }
  end
  
  def test_update_preferences
    user= User.find_by_username("andrew")
    user.preferences = {"display_name" => "andrew", "email" => "", "parse_srm_comment" => false, "view_type" => "index", "sort_order" => "name" }
    user.save!
    assert_equal  "andrew", user.preferences["display_name"]
  end
  
end
