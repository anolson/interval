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
  
  def link_to_workout_download(file)  
    link_to(file.filename, download_path(file))
  end
  
  def link_to_workouts()
    link_to("#{content_tag(:span, '&laquo;', :class=>'huge')} Back to workouts", workouts_path)
  end
  
  def new_workout_header()
    content_tag(:span, "Add a new workout.", :class => "larger")
  end
  
  def workout_header(workout)
    content_tag(:span, workout.name, :class => "larger", :id => "workout_name")
  end

  def workouts_header(count)
    content_tag(:span, "All workouts (#{count})", :class => "larger")
  end
  
  def options_for_workout_navigation(workout)
    [ { :text => 'Summary', :path => workout_path(workout) }, 
      { :text => 'Graph', :path => workout_graph_path(workout) }, 
      { :text => 'Peak Power', :path => workout_peak_power_path(workout) } ]
  end
  
  def options_for_new_workout_navigation()
    [ { :text => 'Upload Workout', :path => new_upload_path }, 
      { :text => 'Add Workout', :path => new_workout_path } ]
  end
  
end
