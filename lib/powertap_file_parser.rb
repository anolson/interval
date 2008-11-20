class PowertapFileParser < CsvFileParser
  MINUTES = 0
  TORQUE = 1
  SPEED = 2
  POWER = 3
  DISTANCE = 4
  CADENCE = 5
  HEARTRATE = 6
  MARKER = 7

  
  def parse_header()
    @data_values = Array.new
    header = CSV.parse(@data).shift
    records = CSV.parse(@data)
    
    @properties = PowertapProperties.new
    @properties.speed_units = header[SPEED].to_s.downcase
    @properties.power_units = header[POWER].to_s.downcase
    @properties.distance_units = header[DISTANCE].to_s.downcase
    calculate_record_interval(records)
  end

  def parse_data_values()
    @data_values = Array.new
    records = CSV.parse(@data) 
    
    # the first marker is for the entire workout.
    parse_workout_marker(records)
    
    records.each_with_index { |record, index|
      data_value = DataValue.new
      data_value.relative_time  = record[MINUTES].to_f * 60
      #data_value.torque = row[TORQUE]
      data_value.speed = convert_speed(record[SPEED].to_f)
      data_value.power = record[POWER].to_i
      data_value.distance = convert_distance(record[DISTANCE].to_f)
      data_value.cadence = record[CADENCE].to_i
      if record[HEARTRATE].to_i < 0
        data_value.heartrate = 0
      else
        data_value.heartrate = record[HEARTRATE].to_i
      end
      #parse markers
      #raise(index.to_s)
      if(index > 0 && (record[MARKER].to_i > records[index-1][MARKER].to_i))
        marker = Marker.new
        marker.start = index
        marker.comment = ""
        set_marker_end(index - 1)
        @markers << marker
      end
      @data_values << data_value
    }
    
    #set the end of the last marker
    set_marker_end(@data_values.size - 1)
  end
  
  def set_marker_end(value)
    if(@markers.size > 0)
      @markers.last.end = value
      @markers.last.duration_seconds = @data_values[@markers.last.end].relative_time - @data_values[@markers.last.start].relative_time
      
    end
  end
  
  def calculate_record_interval(records)
    times = Array.new
    records[1..30].each_slice(2) {|s| times << ((s[1][MINUTES].to_f - s[0][MINUTES].to_f)  * 60) }
    @properties.record_interval = times.average.round
  end
  
  def convert_speed(speed)
    #convert to mm/s
    if @properties.speed_is_english?
      #speed = speed 0.44704
      speed=speed * 447.04 
    else
      #speed = speed 0.27777
      speed=speed * 277.77
    end
    speed
  end
  
  def convert_distance(distance)
    if @properties.distance_is_english?
      #distance = distance * 1609
      distance = distance * 1609344 
    else
      #distance = distance * 1000
      distance = distance * 1000000
    end
    distance
  end
    
  def parse_workout_marker(records)
    @markers = Array.new
    marker = Marker.new
    marker.start = 0
    marker.end = records.size-1
    @markers << marker
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
      #   @data_values[marker.start-1..marker.end-1].collect() {|value| value.distance})  
      
      if marker.start.eql?(0) 
        marker.distance = @data_values.last.distance
        marker.duration_seconds = @data_values.last.relative_time
      else
        marker.distance = @data_values[marker.end].distance - @data_values[marker.start-1].distance
        marker.duration_seconds = @data_values[marker.end].relative_time - @data_values[marker.start-1].relative_time
      end
      
      marker.energy = (marker.avg_power * marker.duration.to_i)/1000

      marker.normalized_power = PowerCalculator::normalized_power( 
          @data_values[marker.start..marker.end].collect() {|value| value.power}, @properties.record_interval)
        
    }
  end
  
end