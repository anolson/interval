module WorkoutsHelper
  
  def format_power_for_graph(power) power.round end
  
  def format_torque_for_graph(torque) torque end
  
  def format_heartrate_for_graph(heartrate) heartrate end

  def format_cadence_for_graph(cadence) cadence end
  
  def format_speed_for_graph(speed) 
    format_speed(speed, {:scale_speed => true}) 
  end
  
  def format_speed(speed, options = {})
    if units_of_measurement.eql?("english")
      format_speed_in_units_of_measurement(convert_speed_to_mph(speed), options)
    else
      format_speed_in_units_of_measurement(convert_speed_to_kmh(speed), options)
    end 
  end
  
  def format_speed_in_units_of_measurement(speed, options = {})
    if(options[:scale_speed])
      speed = speed * 10
    end
    
    if(options[:include_units])
      sprintf("%.1f #{speed_units}", speed)
    else
      #sprintf("%.1f", speed)
      speed.round_with_precision(1)
    end
  end
 
  def format_distance(distance, options = {})
    if units_of_measurement.eql?("english")
      format_distance_in_units_of_measurement(convert_distance_to_miles(distance), options)
    else
      format_distance_in_units_of_measurement(convert_distance_to_kilometers(distance), options)
    end 
  end
  
  def format_distance_in_units_of_measurement(distance, options = {})
    if(options[:include_units])
      sprintf("%.1f #{distance_units}", distance)
    else
      sprintf("%.1f", distance)
    end
  end

  def convert_distance_to_miles(distance)
    distance / 1609344.0
  end

  def convert_distance_to_kilometers(distance)
    distance / 1000000.0
  end  

  def convert_speed_to_mph(speed)
    (speed * 3600) / 1609344.0
  end  
  
  def convert_speed_to_kmh(speed)
    (speed * 3600) / 1000000.0
  end  
  
  def power_units()
    "W"
  end

  def torque_units()
    units_of_measurement.eql?("english") && "ft-lbs" || "N-m"
  end
  
  def heartrate_units()
    "bpm"
  end
  
  def cadence_units()
    "rpm"
  end
      
  def speed_units()
    units_of_measurement.eql?("english") && "mph" || "kmh"
  end
  
  def distance_units()
    units_of_measurement.eql?("english") && "miles" || "km"
  end
  
  def units_of_measurement
    @user.preferences[:units_of_measurement]
  end
  
  def power_plot_line_color() "#00A8F0" end

  def torque_plot_line_color() "#A8F000"end
  
  def heartrate_plot_line_color() "#CB4B4B" end
  
  def cadence_plot_line_color() "#F000A8" end
  
  def speed_plot_line_color() "#00F048" end  
  
  def plot_line_options()
    params.sort.collect{|p| p[0].to_sym}.find_all{|p| available_plot_lines.include?(p)}
  end
  
  def available_plot_lines
    [:power, :torque, :heartrate, :cadence, :speed]
  end
  
  def link_to_workout(workout, format = nil)
    link_to(workout.name, workout_path(workout, :format => format))
  end
end
