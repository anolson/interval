class IBikeFileParser < CsvFileParser
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

  end
  
end