class IbikeFileParser < CsvFileParser
  IBIKE = '.csv'
  SPEED = 0
  WINDSPEED = 1
  POWER = 2
  DISTANCE = 3
  CADENCE = 4
  HEARTRATE = 5
  ELEVATION = 6
  SLOPE = 7
  DFPM_POWER = 11
  LATITUDE = 12
  LONGITUDE = 13
  TIMESTAMP = 14
   

  
  def parse_header()
    @properties = IbikeProperties.new()
    
    records = CSV.parse(@data)
    header = records.shift
    @properties.version=header[1]
    @properties.units=header[2]
    header = records.shift
    @properties.date_time = Time.mktime(header[0].to_i, header[1].to_i, header[2].to_i, header[3].to_i, header[4].to_i, header[5].to_i)
    records.shift
    header = records.shift
    @properties.total_weight = header[0]
    @properties.energy = header[1]
    @properties.record_interval = header[4].to_i
    @properties.starting_elevation = header[5]
    @properties.total_climbing = header[6]
    @properties.wheel_size = header[7]
    @properties.temperature = header[8]
    @properties.starting_pressure = header[9]
    @properties.wind_scaling = header[10]
    @properties.riding_tilt = header[11]
    @properties.calibration_weight = header[12]
    @properties.cm = header[13]
    @properties.cda = header[14]
    @properties.crr = header[15]
    
  end

  def parse_data_values()
    @data_values = Array.new
    records = CSV.parse(@data).slice(5..-1)
    records.each_with_index { |record, index|
      data_value  = DataValue.new
      data_value.relative_time  = index * @properties.record_interval
      data_value.speed = convert_speed(record[SPEED].to_f)
      data_value.power = record[POWER].to_i
      data_value.distance = convert_distance(record[DISTANCE].to_f)
      data_value.cadence = record[CADENCE].to_i
      data_value.heartrate = record[HEARTRATE].to_i
      @data_values << data_value 
    }

  end
  
  def parse_markers
    @markers = Array.new
    records = CSV.parse(@data).slice(5..-1)
    @markers << parse_workout_marker(records)
  end
  
  def parse_workout_marker(records)
    Marker.new(:start => 0, :end => records.size - 1)
  end
  
  def convert_speed(speed)
    #convert to mm/s
    if @properties.units_are_english?
      speed * 447.04 
    else
      speed * 277.77
    end
  end
  
  def convert_distance(distance)
    #convert distacen to mm
    if @properties.units_are_english?
      distance * 1609344 
    else
      distance * 1000000
    end
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