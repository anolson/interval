require File.dirname(__FILE__) + '/../test_helper'

class TrainingFileTest < Test::Unit::TestCase
  #fixtures :training_files
   
  # def test_create
  #   file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/A050108A.srm")
  #   #training_file = TrainingFile.create({:payload => file})
  #   
  #   training_file = TrainingFile.create({:payload => file})
  #   training_file.save
  #   training_file.parse_file_header()
  #   training_file.parse_file_data()
  #   
  #   assert_equal ".srm", training_file.file_type
  #   assert_equal 'A050108A.srm', training_file.filename
  #   assert_equal 1241, training_file.powermeter_properties.record_count
  #   #p training_file.powermeter_properties
  #   #assert true
  # end
  # 
  # def test_create_powertap
  #   file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/11202008.csv")
  #   #training_file = TrainingFile.create({:payload => file})
  #   
  #   training_file = TrainingFile.create({:payload => file})
  #   training_file.save
  #   training_file.parse_file_header()
  #   training_file.parse_file_data()
  #   
  #   assert_equal ".csv", training_file.file_type
  #   assert_equal 5, training_file.markers.size
  #   assert_equal 137, training_file.markers.first.avg_power
  # end
  
  def test_create_ibike
    file = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/Owen.09142008.csv")
    #training_file = TrainingFile.create({:payload => file})
    
    training_file = TrainingFile.create({:payload => file})
    training_file.parse_file_header()
    training_file.parse_file_data()
    training_file.save
    
    
    assert_equal ".csv", training_file.file_type
    assert_equal 1, training_file.powermeter_properties.record_interval
    assert_equal "09/14/08 16:41:52", training_file.powermeter_properties.date_time.strftime("%m/%d/%y %H:%M:%S")
    assert_equal "english", training_file.powermeter_properties.units
    assert_equal 31.56, (training_file.data_values.last.distance/1609344).round_with_precision(2)
    assert_equal 211, training_file.markers.first.avg_power
    assert_equal 25.39, (training_file.markers.first.avg_speed/447).round_with_precision(2)
    
  end
    
end
