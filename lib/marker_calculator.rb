module MarkerCalculator
  def calculate_marker_averages(marker)
    marker.avg_power=PowerCalculator::average(
      self.data_values[marker.start..marker.end].collect() {|value| value.power})
    
    marker.avg_speed=PowerCalculator::average(
      self.data_values[marker.start..marker.end].collect() {|value| value.speed})
    
    marker.avg_cadence=PowerCalculator::average(
      self.data_values[marker.start..marker.end].collect() {|value| value.cadence})
    
    marker.avg_heartrate=PowerCalculator::average(
      self.data_values[marker.start..marker.end].collect() {|value| value.heartrate})
  end
  
  def calculate_marker_maximums(marker)
    marker.max_power=PowerCalculator::maximum(
      self.data_values[marker.start..marker.end].collect() {|value| value.power})
    
    marker.max_speed=PowerCalculator::maximum(
      self.data_values[marker.start..marker.end].collect() {|value| value.speed})
    
    marker.max_cadence=PowerCalculator::maximum(
      self.data_values[marker.start..marker.end].collect() {|value| value.cadence})
    
    marker.max_heartrate=PowerCalculator::maximum(
      self.data_values[marker.start..marker.end].collect() {|value| value.heartrate})
  end
  
  def calculate_marker_training_metrics(marker)
    marker.normalized_power = PowerCalculator::normalized_power( 
       self.data_values[marker.start..marker.end].collect() {|value| value.power}, self.properties.record_interval)
  end
  
  
end