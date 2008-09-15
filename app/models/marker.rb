class Marker < ActiveRecord::Base
  belongs_to :workout
  belongs_to :training_file
  
  #attr_accessor for duration
  attr_accessor :minute
  attr_accessor :hour
  
  def initialize(params = {})
    super(params)
    self.duration_seconds = (@minute.to_i * 60) + (@hour.to_i * 3600)
  end
  
  def duration=(params = {})
    self.duration_seconds = (params[:minute].to_i * 60) + (params[:hour].to_i * 3600)
  end
  
  def duration 
    Time.at(self.duration_seconds).utc
  end
end
