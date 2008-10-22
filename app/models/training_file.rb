require 'srm_file_parser'
require 'powertap_file_parser'

class TrainingFile < ActiveRecord::Base
  serialize :powermeter_properties
  belongs_to :workout
  #has_many :markers,  :dependent => :destroy
  has_many :data_values, :order => 'id', :dependent => :destroy
  
  attr_accessor :markers
  
  def initialize(params = {})
    super(params)
    parse_file_header
  end
  
  def payload=(file = {})
    write_attribute(:payload, file.read)
    self.filename=sanitize_filename(file.original_filename)
  end
  
  def file_type 
    self.filename.split('.').last
  end
  
  def is_srm_file_type?()
    return self.file_type.eql?(SrmParser::SRM)
  end
  
  def performed_on
    date = powermeter_properties.date
    Time.mktime(date.year.to_i, date.month.to_i, date.day.to_i, 0, 0, 0, 0) + data_values.first.absolute_time.to_i
  end
  
  def parse_file_data()
    file_parser = get_file_parser()
    file_parser.parse_training_file(self.payload)
    self.data_values.push(file_parser.data_values)
    @markers = file_parser.markers
  end
  
  private
    def sanitize_filename(filename)
      # get only the filename, not the whole path
      filename.split('\\').last.gsub(/[^\w\.\-]/,'_') 
    end 
        
    def parse_file_header()
      file_parser = get_file_parser()
      file_parser.data = self.payload
      file_parser.parse_header()
      self.powermeter_properties=file_parser.properties
    end
    
    def get_file_parser()
      if self.is_srm_file_type?()
        SrmParser.new
      else
        PowertapParser.new
      end
    end
      
end
