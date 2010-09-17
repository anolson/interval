# require 'srm_file_parser'
# require 'csv_file_parser'
# require 'ibike_file_parser'

require 'joule'

class TrainingFile < ActiveRecord::Base
  unloadable
  
  serialize :powermeter_properties
  belongs_to :workout
  has_many :data_values, :order => 'id', :dependent => :destroy

  attr_accessor :markers, :peak_powers

  def payload=(file = {})
    write_attribute(:payload, file.read)
    self.filename = file.original_filename
  end

  def file_size
    payload.length
  end
  
  def file_basename 
    File.basename(self.filename, self.file_type)
  end
  
  def file_type 
    File.extname(self.filename)
  end
  
  def is_srm_file_type?()
    return self.file_type.eql?(".srm")
  end
  
  def has_performed_on_date_time?
    self.powermeter_properties.class.eql?(Joule::IBike::Properties) || self.powermeter_properties.class.eql?(Joule::SRM::Properties)
  end
  
  def auto_assign_options
    if(self.has_performed_on_date_time?)
      { :performed_on => self.powermeter_properties.date_time }
    end
  end
  
  
  def parse_file_data()
    parser = Joule::parser("srm", self.payload)
    workout = parser.parse(
      :calculate_marker_values => true,
      :calculate_peak_power_values => true,
      :durations => PeakPower::DURATIONS)
      
    self.data_values << workout.data_points.collect { |v| DataValue.new(v.to_hash) }
    self.powermeter_properties = workout.properties
    @markers = workout.markers
    @peak_powers = workout.peak_powers
  end
  
  private
    #def sanitize_filename(filename)
      # get only the filename, not the whole path
    #  filename.split('\\').last.gsub(/[^\w\.\-]/,'_') 
    #end 

    def validate_on_create 
      regex = %r{\.(srm|csv|tcx)$}i
      errors.add("filename", "is an unsupported format") unless self.filename.match(regex)
    end
    
      
end
