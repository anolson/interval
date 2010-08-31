require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  include WorkoutsHelper
  
  def test_link_to_workouts
    render :text => link_to_workouts
    assert_select 'a[href="/workouts"]'
  end
end
