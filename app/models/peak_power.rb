class PeakPower < ActiveRecord::Base
  DURATIONS = [5, 60, 300, 1200, 3600, 7200]
  belongs_to :workout
end
