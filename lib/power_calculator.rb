class Array
  def sum
    inject{|sum, value| sum + value}
  end
  
  def maximum
    inject {|max, value| value>max ? value : max}
  end
  
  def average
    sum/length
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
  
  def intesityFactor
  end
  
  def trainingStressScore
  end
  
end
