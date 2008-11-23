class PowertapProperties
  TYPE = "powertap"
  ENGLISH_SPEED_UNITS = "miles/h"
  ENGLISH_POWER_UNITS = "watts"
  ENGLISH_DISTANCE_UNITS = "miles"
  
  METRIC_SPEED_UNITS = "km/h"
  METRIC_POWER_UNITS = "watts"
  METRIC_DISTANCE_UNITS = "km"
  
  attr_accessor :type, :speed_units, :power_units, :distance_units, :record_interval
  
  def initialize()
    self.type=TYPE
  end
  
  
  def speed_is_english?()
    return self.speed_units.eql?(ENGLISH_SPEED_UNITS)
  end
  
  def speed_is_metric?()
    return self.speed_units.eql?(METRIC_SPEED_UNITS)
  end
  
  def distance_is_english?()
    return self.distance_units.eql?(ENGLISH_DISTANCE_UNITS)
  end
  
  def distance_is_metric?()
    return self.distance_units.eql?(METRIC_DISTANCE_UNITS)
  end
  
  def date
    Date.new
  end
  

end

