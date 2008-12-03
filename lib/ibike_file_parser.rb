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
    records = CSV.parse(@data).slice(5..-1)
    records.each_with_index { |record, index|
      data_value  = DataValue.new
      data_value.relative_time  = index * @properties.record_interval
      data_value.speed = convert_speed(record[SPEED].to_f)
      data_value.power = record[POWER].to_f
      data_value.distance = convert_distance(record[DISTANCE].to_f)
      data_value.cadence = record[CADENCE].to_i
      data_value.heartrate = record[HEARTRATE].to_i
      @data_values << data_value 
    }
  end
  
  def parse_markers
    records = CSV.parse(@data).slice(5..-1)
    @markers << parse_workout_marker(records)
  end
  
end