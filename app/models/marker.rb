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
    if(power_to_weight.nil?)
      power_to_weight = calculate_power_to_weight(average_power, weight)
      update_attribute(:average_power_to_weight, power_to_weight)    
    end
    power_to_weight.nil? && 0.0 || power_to_weight
  end
  
  def maximum_power_to_weight(weight)
    power_to_weight = read_attribute(:maximum_power_to_weight)
    if(power_to_weight.nil?)
      power_to_weight = calculate_power_to_weight(maximum_power, weight)
      update_attribute(:maximum_power_to_weight, power_to_weight)    
    end
    power_to_weight.nil? && 0.0 || power_to_weight
  end
  
  def calculate_power_to_weight(power, weight)
    if(weight > 0)
      (power/weight).round_with_precision(2)
    end
  end
  
  def tss_if(threshold_power)
    "#{training_stress_score(threshold_power)}/#{intensity_factor(threshold_power)}"
  end
  
  def training_stress_score(threshold_power)
    training_stress_score_value = read_attribute(:training_stress_score)
    if(training_stress_score_value.nil?)
      training_stress_score_value = calculate_training_stress_score(threshold_power)
      update_attribute(:training_stress_score, training_stress_score_value)
    end
    training_stress_score_value.nil? && 0 || training_stress_score_value.round
  end

  def calculate_training_stress_score(threshold_power)
    if(threshold_power > 0)
      normalized_work = normalized_power * duration_seconds
      raw_training_stress_score = normalized_work * intensity_factor(threshold_power)
      (raw_training_stress_score/(threshold_power * 3600)) * 100
    end
  end

  def intensity_factor(threshold_power)
    intensity_factor_value = read_attribute(:intensity_factor)
    if(intensity_factor_value.nil?)
      intensity_factor_value = calculate_intensity_factor(threshold_power)
      update_attribute(:intensity_factor, intensity_factor_value)    
    end
    intensity_factor_value.nil? && 0.0 || intensity_factor_value.round_with_precision(3)
  end
  
  def calculate_intensity_factor(threshold_power)
    if(threshold_power > 0)
      normalized_power/threshold_power
    end
  end
  
end
