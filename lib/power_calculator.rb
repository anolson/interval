class Array
  #def sum
  #  inject{|sum, value| sum + value}
  #end
  
  def maximum
    inject {|max, value| value>max ? value : max}
  end
  
  def average
    sum/length
  end
  
  def average_maximum(size)
    mean_max = {:start => 0, :value=> 0}
      each_index do |i|
        mean = slice(i, size).average
        mean > mean_max[:value] &&  mean_max = {:start => i, :value => mean}
      end
    mean_max
  end
end

class PowerCalculator
  def PowerCalculator.average(values)
    values.average
  end
  
  def PowerCalculator.maximum(values)
    values.maximum
  end
  
  def PowerCalculator.total(values)
    values.sum
  end
  
  def PowerCalculator.peak_power(values, size)
    values.average_maximum size
  end

  def PowerCalculator.training_stress_score(values)
  end
  
  def PowerCalculator.intesity_factor(values)
  end
  
  def PowerCalculator.normalized_power(values, record_interval)
    thirty_second_record_count = 30 / record_interval
    thirty_second_rolling_power = Array.new
    if(values.length > thirty_second_record_count)
      values.slice(thirty_second_record_count..-1).each_slice(thirty_second_record_count) { |s|
        thirty_second_rolling_power << s.average ** 4
      }
      thirty_second_rolling_power.average ** 0.25
    else
      0
    end
  end
  
  
  


  
end
