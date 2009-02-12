require 'power_calculator.rb'

require 'training_file'
require 'marker'
require 'data_value'

#require 'FasterCSV'

class CsvFileParser
  include MarkerCalculator
  include PeakPowerCalculator
  include UnitsConverter
  
  attr_writer :data
  attr_reader :data, :properties, :markers, :data_values, :peak_powers
  
  
  def initialize(data)
    self.data = data
    @markers = Array.new
    @data_values = Array.new
    @peak_powers = Array.new
  end
  
  def get_parser
    header = FasterCSV.parse(@data).shift
    if header[0].to_s.downcase.eql?("ibike")
      return IbikeFileParser.new(data)
    else
      return PowertapFileParser.new(data)
    end
  end
  
  def parse_training_file
    parse_header
    parse_markers
    parse_data_values
    calculate_marker_values
    calculate_peak_power_values
  end

  protected
  def parse_workout_marker(records)
    Marker.new(:start => 0, :end => records.size - 1, :comment => "")
  end
  
  def calculate_marker_values
    @markers.each_with_index { |marker, i|
      calculate_marker_averages marker      
      calculate_marker_maximums marker
      calculate_marker_training_metrics marker
  
      if i.eql?(0) 
        marker.distance = @data_values.last.distance
        marker.duration_seconds = @data_values.last.time
      else
        marker.distance = @data_values[marker.end].distance - @data_values[marker.start].distance
        marker.duration_seconds = @data_values[marker.end].time - @data_values[marker.start].time
      end
            
      marker.energy = (marker.avg_power.round * marker.duration.to_i)/1000        
    }
  end
  
end