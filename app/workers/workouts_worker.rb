class WorkoutsWorker < Workling::Base
  def parse_workout(options)
    #user = User.find(options[:user_id])
    #workout = Workout.new(options[:params][:workout], options[:params][:training_file], user.preferences)
    #workout.user = user
    #workout.status = "finished."
    #workout.save!
    logger.info("Processing Workout")
    workout = Workout.find(options[:workout_id])
    training_file = workout.training_files.first
    training_file.parse_file_data
    workout.markers << training_file.markers
    workout.peak_powers << training_file.peak_powers.collect {|p| PeakPower.new(p) }
    
    if training_file.powermeter_properties.class.eql?(IbikeProperties) || 
      training_file.powermeter_properties.class.eql?(SrmProperties)
      workout.auto_assign(:performed_on => training_file.powermeter_properties.date_time)
    end
    
    workout.save
    workout.finish!
    
    logger.info("Done Processing Workout")
  end
  
  def destroy_workout(options)
    Workout.destroy(options[:workout_id])
  end
end