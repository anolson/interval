require File.dirname(__FILE__) + '/../test_helper'

class MarkerTest < Test::Unit::TestCase
  fixtures :markers

  # Replace this with your real tests.
  def test_create
    marker = Marker.create(:minute => '30', :hour => '1') 
    assert 5400, marker.duration
  end
end
