class PeakPower < ActiveRecord::Base
  DURATIONS = [5, 60, 300, 1200, 3600, 7200]
  belongs_to :workout
  belongs_to :user
  
  def PeakPower.maximum_peak_power(duration)
    self.calculate(:max, :value, :conditions => ['duration = ?', duration]).round
  end
end
