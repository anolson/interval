require File.dirname(__FILE__) + '/../test_helper'

class WorkoutTest < ActiveSupport::TestCase
  fixtures :workouts, :users

  def test_create
    user = User.find_by_username('eddy')
    workout = Workout.create({:name => "Endurance Ride", :notes => "Big Miles", :performed_on => Time.now, :user => user})
    assert_equal "Endurance Ride", workout.name
  end
  
  def test_validate_presence_of_name
    user = User.find_by_username('andrew')
    workout = Workout.create({:name => "", :notes => "Workout without a name.", :performed_on => Time.now, :user => user})
    assert "New Workout", workout.name
  end
  
  def test_find_others_workouts_fails
    user = User.find_by_username('andrew')
    workout = Workout.find_by_id_and_user_id(2, user.id)
    assert_nil workout
  end
  
  def test_find_by_date_range
    date = Date.strptime('2008-5-5')
    workouts = Workout.find_by_date_range(date..date+7, 2)
    assert 2, workouts.length
  end
  
end