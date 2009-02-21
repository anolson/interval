module PeakPowerCalculator
  def calculate_peak_power_values(total_duration)
    power_values = @data_values.collect{|v| v.power}
    PeakPower::DURATIONS.each { |duration|
      @peak_powers << calculate_peak_power_value(duration, total_duration, power_values)
    }
    
  end
  
  def calculate_peak_power_value(duration, total_duration, power_values)
    if duration > total_duration
      { :duration => duration, 
        :value => 0,
        :start => 0 } 
    else
       peak_power = PowerCalculator::peak_power(power_values, (duration/@properties.record_interval))
       { :duration => duration, 
         :value => peak_power[:value],
         :start => peak_power[:start] }
    end
  end
end