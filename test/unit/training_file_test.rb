require File.dirname(__FILE__) + '/../test_helper'

class TrainingFileTest < ActiveSupport::TestCase
   
  def test_create
   file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
   training_file = TrainingFile.create({:payload => file})
   training_file.parse_file_data()

   assert_equal ".srm", training_file.file_type
   assert training_file.has_performed_on_date_time?
 end
    
end
