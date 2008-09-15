require File.dirname(__FILE__) + '/../test_helper'

class TrainingFileTest < Test::Unit::TestCase
  fixtures :training_files
   
  def test_create
    file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
    training_file = TrainingFile.create({:payload => file})
    assert_equal "srm", training_file.file_type
    assert_equal 'A050108A.srm', training_file.filename
    assert_equal 1241, training_file.powermeter_properties.record_count
  end
end
