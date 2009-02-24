class Marker < ActiveRecord::Base
  belongs_to :workout
  belongs_to :training_file
  
  #attr_accessor for duration
  attr_accessor :hour
  attr_accessor :minute
  attr_accessor :second
  
  def initialize(params = {})
    super(params)
    self.duration_seconds = (@hour.to_i * 3600) + (@minute.to_i * 60) + @second.to_i
  end
  
  def duration=(params = {})
    self.duration_seconds = (params[:hour].to_i * 3600) + (params[:minute].to_i * 60) + params[:second].to_i
  end
  
  def duration 
    Time.at(self.duration_seconds).utc
  end
  
  def average_power_to_weight(weight)
    power_to_weight = read_attribute(:average_power_to_weight)
    if(power_to_weight > 0)
      power_to_weight
    else
      if(weight > 0)
        write_attribute(:average_power_to_weight, (avg_power/weight).round_with_precision(2))
      end
    end
  end
  
end
