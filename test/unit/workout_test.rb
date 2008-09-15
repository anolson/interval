require File.dirname(__FILE__) + '/../test_helper'

class WorkoutTest < Test::Unit::TestCase
  fixtures :workouts, :users

  # Replace this with your real tests.
  def test_create
    user = User.find_by_username('eddy')
    workout = Workout.create({:name => "Endurance Ride", :notes => "Big Miles", :performed_on => Time.now, :user => user})
    assert_equal "endurance_ride", workout.permalink
  end
  
  def test_validate_presence_of_name
    user = User.find_by_username('andrew')
    workout = Workout.create({:name => "", :notes => "Invalid Ride", :performed_on => Time.now, :user => user})
    assert workout.errors.on(:name)
  end
  
  def test_validate_unique_name_for_day
    user = User.find_by_username('andrew')
    workout = Workout.create({:name => "RR", :notes => "Invalid Ride", :performed_on => Time.now, :user => user})
    assert workout.errors.on(:name)
  end
  
  def test_find_by_permalink
    user = User.find_by_username('andrew')
    today = Time.now
    workout = Workout.find_by_permalink('rr', user.id, today.year, today.month, today.day)
    assert 'rr', workout.permalink
    assert 'RR on the bike path.', workout.notes
    assert 'RR', workout.name
    assert user, workout.user
  end
  
  def test_find_others_workouts_fails
    user = User.find_by_username('andrew')
    today = Time.now
    workout = Workout.find_by_permalink('paris_roubaix', user.id, today.year, today.month, today.day)
    assert_nil workout
  end
  
  def test_find_by_date_range
    date = Date.strptime('2008-5-5')
    workouts = Workout.find_by_date_range(date..date+7, 2)
    assert 2, workouts.length
  end
  
  
end