require 'srm_block.rb'
require 'srm_properties.rb'
require 'power_calculator.rb'

require 'training_file'
require 'marker'
require 'data_value'

require 'csv'

class CsvFileParser
  attr_writer :data
  attr_reader :data, :properties, :markers, :data_values
  
  
  def initialize(data)
    self.data = data
    
  end
  
  def get_parser
    header = CSV.parse(@data).shift
    unless header[0].to_s.downcase.eql?("ibike")
      return PowertapFileParser.new(data)
    end
  end
  
  def parse_training_file
    parse_header
    parse_markers
    parse_data_values
    calculate_marker_values
  end

  def parse_header
  end
  
  def parse_data_values
  end
  
  def calculate_marker_values
  end
  
end