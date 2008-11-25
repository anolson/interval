

# If you open it in Excel, row 2 is y,m,d,h,m,s
#  
# 4A = total weight (lb or kg)
# 4B = energy (kJ)
# 4C & 4D = aero and fric <---<<< You shouldn't need to worry about those
# 4E = recording time (1s or 5s)
# 4F = starting elevation (ft or m)
# 4G = cumulative climbing (ft or m)
# 4H = wheel circ (mm)
# 4I = average temperature (degF or degC)
# 4J = starting pressure (mbar)
# 4L = wind_scaling
# 4M = riding_tilt
# 4N = calibration weight (lb or kg)
# 4P = Cm
# 4Q = CdA
# 4R = Crr


class IbikeProperties
  ENGLISH_UNITS = "english"
  METRIC_UNITS = "metric"

  attr_accessor :version, :units, :date_time, :total_weight, :energy, :record_interval, :starting_elevation, :total_climbing, 
  :wheel_size, :temperature, :starting_pressure, :wind_scaling, :riding_tilt, :calibration_weight, :cm, :cda, :crr
  
  def distance_units_are_english?
    self.units_are_english?
  end
  
  def speed_units_are_english?
    self.units_are_english?
  end
  
  def units_are_english?
    self.units.eql?(ENGLISH_UNITS)
  end
  
  def units_are_metric?
    self.units.eql?(METRIC_UNITS)
  end
  
end

