module UnitsConverter
  def convert_speed(speed)
    #convert to mm/s
    if self.properties.speed_units_are_english?
      speed * 447.04 
    else
      speed * 277.77
    end
  end
  
  def convert_distance(distance)
    #convert distance to mm
    if self.properties.distance_units_are_english?
      distance * 1609344 
    else
      distance * 1000000
    end
  end
end