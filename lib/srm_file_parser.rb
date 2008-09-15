require 'srm_block.rb'
require 'srm_properties.rb'
require 'power_calculator.rb'

require 'training_file'
require 'marker'
require 'data_value'


class SrmParser
  HEADER_SIZE=86
  MARKER_SIZE=270
  BLOCK_SIZE=6
  
  attr_writer :data
  attr_reader :blocks, :data, :properties, :markers, :data_values
  
  def parse_training_file(data)
    self.data = data
    parse_header
    parse_markers
    parse_blocks
    parse_data_values
    parse_data_value_times
    calculate_marker_values
    
  end
  
  def parse_header()
    str = @data.slice(0, HEADER_SIZE)
    @properties = SrmProperties.new
    @properties.ident=str.slice(0,4)
    @properties.srm_date = str.slice(4,2).unpack('S')[0]
    @properties.wheel_size = str.slice(6,2).unpack('S')[0]
    @properties.record_interval_numerator = str.slice(8,1).unpack('C')[0]
    @properties.record_interval_denominator = str.slice(9,1).unpack('C')[0]
    @properties.block_count = str.slice(10,2).unpack('S')[0]
    @properties.marker_count = str.slice(12,2).unpack('S')[0]
    @properties.comment = str.slice(16,70).toutf8.strip
  
    str=@data.slice(HEADER_SIZE + 
      (MARKER_SIZE * (@properties.marker_count + 1 )) + 
      (BLOCK_SIZE * @properties.block_count) , 6)
    
    @properties.zero_offset = str.slice(0,2).unpack('S')[0]
    @properties.slope = str.slice(2,2).unpack('S')[0]
    @properties.record_count = str.slice(4,2).unpack('S')[0]   
  end

  def parse_markers
    start = HEADER_SIZE
    count=0
    @markers = Array.new
    while count <= @properties.marker_count 
      str = @data.slice(start + (count * MARKER_SIZE ), MARKER_SIZE)
      
      @markers[count]=Marker.new
      @markers[count].comment = str.slice(0, 255).strip
      @markers[count].active = str.slice(255)
      @markers[count].start = str.slice(256,2).unpack('S')[0] - 1
      @markers[count].end = str.slice(258,2).unpack('S')[0] - 1
      #@markers[count].duration = Time.at((@markers[count].end - @markers[count].start + 1) * @properties.record_interval).utc
      @markers[count].duration_seconds = (@markers[count].end - @markers[count].start + 1) * @properties.record_interval
      count=count + 1
    end
  end
  
  def parse_blocks
    count = 0
    start = HEADER_SIZE + (MARKER_SIZE * (@properties.marker_count + 1 ))
    @blocks = Array.new
    while count < @properties.block_count
      str=@data.slice(start + (count * BLOCK_SIZE), BLOCK_SIZE)
      @blocks[count]=SrmBlock.new
      @blocks[count].time=str.slice(0,4).unpack('I')[0]
      @blocks[count].count=str.slice(4,2).unpack('S')[0].to_i
      count = count + 1
    end
  end
  
  def parse_data_values()
    count = 0
    start = HEADER_SIZE + (MARKER_SIZE * (@properties.marker_count + 1 )) + (BLOCK_SIZE * @properties.block_count) + 7
    total_distance = 0
    @data_values = Array.new
    while count < @properties.record_count
      record=@data.slice(start + (count * 5), 5)
      byte1=record.slice(0)
      byte2=record.slice(1)
      byte3=record.slice(2)
      @data_values[count]=DataValue.new
      @data_values[count].power = ( (byte2 & 0x0F) | (byte3 << 4) )
      @data_values[count].speed = ( ( ( (byte2 & 0xF0) << 3) | (byte1 & 0x7F) ) * 32 ) #stored in mm/s
      @data_values[count].cadence = record.slice(3)
      @data_values[count].heartrate = record.slice(4)
      #@data_values[count].distance = @data_values[count].speed * @properties.record_interval
      total_distance = total_distance + (@data_values[count].speed * @properties.record_interval) 
      @data_values[count].distance = total_distance #in mm
      
      #print " ** " + record.slice(4).to_s
      
      count=count + 1
    end
  end
  
  def parse_data_value_times
    count = 0
    block_count=0

    while block_count < @blocks.length
      relative_count = 0
      while relative_count < @blocks[block_count].count
        #@data_values[count].absolute_time =  Time.at(@blocks[block_count].time/100).utc + (@properties.record_interval*relative_count)
        #@data_values[count].relative_time = Time.at(@blocks[block_count].time/100 - @blocks[0].time/100).utc + (@properties.record_interval*relative_count)
        @data_values[count].absolute_time =  @blocks[block_count].time/100 + (@properties.record_interval*relative_count)
        @data_values[count].relative_time = @blocks[block_count].time/100 - @blocks[0].time/100 + (@properties.record_interval*(relative_count + 1))
        
        count=count+1
        relative_count=relative_count+1
      end
      block_count=block_count + 1
    end
  end
  
  def calculate_marker_values
    @markers.each { |marker|
      
      marker.avg_power=PowerCalculator::average(
        @data_values[marker.start..marker.end].collect() {|value| value.power})
      
      marker.avg_speed=PowerCalculator::average(
        @data_values[marker.start..marker.end].collect() {|value| value.speed})
      
      marker.avg_cadence=PowerCalculator::average(
        @data_values[marker.start..marker.end].collect() {|value| value.cadence})
      
      marker.avg_heartrate=PowerCalculator::average(
        @data_values[marker.start..marker.end].collect() {|value| value.heartrate})
      
      marker.max_power=PowerCalculator::maximum(
        @data_values[marker.start..marker.end].collect() {|value| value.power})
      
      marker.max_speed=PowerCalculator::maximum(
        @data_values[marker.start..marker.end].collect() {|value| value.speed})
      
      marker.max_cadence=PowerCalculator::maximum(
        @data_values[marker.start..marker.end].collect() {|value| value.cadence})
      
      marker.max_heartrate=PowerCalculator::maximum(
        @data_values[marker.start..marker.end].collect() {|value| value.heartrate})
        
      #marker.distance =  PowerCalculator::total(
      #   @data_values[marker.start..marker.end].collect() {|value| value.distance})
      
      if marker.start.eql?(0)
        marker.distance = @data_values.last.distance
      else
        marker.distance = @data_values[marker.end].distance - @data_values[marker.start-1].distance
      end  
      
      marker.energy = (marker.avg_power * marker.duration.to_i)/1000        
    }
  end
  
end