class SrmProperties
  attr_accessor :ident, :srm_date, :start_date_time, :wheel_size, :record_interval_numerator,
    :record_interval_denominator, :block_count, :marker_count, :comment, 
    :zero_offset, :record_count, :slope
    
  def record_interval 
    return self.record_interval_numerator/self.record_interval_denominator
  end
  
  def date
    Date.new(1880,1,1) + self.srm_date
  end
  
  def slope
    @slope/305.58
  end

  def date_time=(time)
    self.start_date_time = Time.mktime(self.date.year.to_i, self.date.month.to_i, self.date.day.to_i) + time
  end
  
  def date_time
    self.start_date_time
  end
end