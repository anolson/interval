module PeakPowerCalculator
  def calculate_peak_power_values
    power_values = @data_values.collect{|v| v.power}
    PeakPower::DURATIONS.each {|duration|
      peak_power = PowerCalculator::peak_power(power_values, (duration/@properties.record_interval))
      @peak_powers << {
        :duration => duration, 
        :value => peak_power[:value],
        :start => peak_power[:start]}
    }
  end
end