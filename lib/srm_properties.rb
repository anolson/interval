require "yaml"

class SrmProperties
  
  attr_accessor :ident, :srm_date, :wheel_size, :record_interval_numerator,
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
  
      
end