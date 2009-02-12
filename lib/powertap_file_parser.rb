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
    header = FasterCSV.parse(@data).shift
    records = FasterCSV.parse(@data) 
    @properties = PowertapProperties.new
    @properties.speed_units = header[SPEED].to_s.downcase
    @properties.power_units = header[POWER].to_s.downcase
    @properties.distance_units = header[DISTANCE].to_s.downcase
    calculate_record_interval(records)
  end

  def parse_data_values()
    records = FasterCSV.parse(@data) 
    records.shift
    
    records.each_with_index { |record, index|
      data_value = DataValue.new
      data_value.time  = record[MINUTES].to_f * 60
      data_value.torque = record[TORQUE]
      data_value.speed = convert_speed(record[SPEED].to_f)
      data_value.power = record[POWER].to_f
      data_value.distance = convert_distance(record[DISTANCE].to_f)
      data_value.cadence = record[CADENCE].to_i
      (record[HEARTRATE].to_i < 0) && data_value.heartrate = 0 || data_value.heartrate = record[HEARTRATE].to_i

      self.data_values << data_value
    }  
  end
  
  def parse_markers
    # @markers = Array.new
    records = FasterCSV.parse(@data) 
    records.shift
    @markers << parse_workout_marker(records)
    
    @markers << Marker.new(:start => 0, :comment => "")
    records.each_with_index { |record, index|
        if(record[MARKER].to_i > records[index-1][MARKER].to_i) 
          marker = Marker.new(:start => index, :comment => "")
          set_previous_marker_end(index - 1)
          @markers << marker
        end
    }
    #set the end of the last marker
    set_previous_marker_end(records.size - 1)  
  end
  
  # def parse_workout_marker(records)
  #   Marker.new(:start => 0, :end => records.size - 1, :comment => "")
  # end
  
  def set_previous_marker_end(value)
    if(@markers.size > 1)
      @markers.last.end = value
    end
  end
  
  def calculate_record_interval(records)
    times = Array.new
    records[1..30].each_slice(2) {|s| times << ((s[1][MINUTES].to_f - s[0][MINUTES].to_f)  * 60) }
    @properties.record_interval = times.average.round
  end
  
end