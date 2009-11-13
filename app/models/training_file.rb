require 'srm_file_parser'
#require 'powertap_file_parser'

require 'csv_file_parser'
require 'ibike_file_parser'

class TrainingFile < ActiveRecord::Base
  serialize :powermeter_properties
  belongs_to :workout
  #has_many :markers,  :dependent => :destroy
  has_many :data_values, :order => 'id', :dependent => :destroy
  
  #before_create :validate_file_type
  
  #validates_format_of :filename, :with => %r{\.(csv|srm)$}
  

  attr_accessor :markers, :peak_powers
  
  def initialize(params = {})
    super(params)
    parse_file_header
  end
    
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
    return self.file_type.eql?(SrmParser::SRM)
  end
 
  def is_ibike_file_type?()
     return self.file_type.eql?(IbikeFileParser::IBIKE)
  end
  
  def has_performed_on_date_time
    self.powermeter_properties.class.eql?(IbikeProperties) || self.powermeter_properties.class.eql?(SrmProperties)
  end
  
  def parse_file_data()
    file_parser = get_file_parser()
    file_parser.parse_training_file
    self.data_values.push(file_parser.data_values)
    self.powermeter_properties=file_parser.properties
    @markers = file_parser.markers
    @peak_powers = file_parser.peak_powers
  end
  
  def parse_file_header()
    file_parser = get_file_parser()
    file_parser.data = self.payload
    file_parser.parse_header()
    self.powermeter_properties=file_parser.properties
  end
  
  private
    #def sanitize_filename(filename)
      # get only the filename, not the whole path
    #  filename.split('\\').last.gsub(/[^\w\.\-]/,'_') 
    #end 

    def validate_on_create 
      regex = %r{\.(srm|csv)$}i
      errors.add("filename", "is an unsupported format") unless self.filename.match(regex)
    end
    
    def get_file_parser()
      if self.is_srm_file_type?()
        SrmParser.new(self.payload)
      else
        CsvFileParser.new(self.payload).get_parser
      end
    end
      
end
