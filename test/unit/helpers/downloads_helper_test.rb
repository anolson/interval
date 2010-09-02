require 'test_helper'

class DownloadsHelperTest < ActionView::TestCase
  include WorkoutsHelper
  fixtures :training_files
  
  def test_link_to_workouts
    file = TrainingFile.find(1)
    render :text => link_to_workout_download(file)
    assert_select 'a[href="/downloads/1"]'
  end
end
