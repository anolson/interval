class WorkoutsWorker < Workling::Base
  def process_workout(options)
    workout = Workout.find(options[:workout_id])
    logger.info("Processing Workout -- ID: #{workout.id}")
    
    training_file = workout.training_files.first
    training_file.parse_file_data
    
    workout.markers << training_file.markers
    workout.peak_powers << training_file.peak_powers.collect {|p| PeakPower.new(p) }
    workout.auto_assign auto_assign_options(workout.user, training_file)
    workout.save
    workout.finish!
    
    logger.info("Done Processing Workout -- ID: #{workout.id}")
  end
  
  def destroy_workout(options)
    Workout.destroy(options[:workout_id])
  end
  
  private  
    def auto_assign_options(user, training_file)
      { :auto_assign_name => user.preferences[:auto_assign_workout_name],
        :auto_assign_name_by => user.preferences[:auto_assign_workout_name_by],
        :append_srm_comment_to_notes => user.preferences[:append_srm_comment_to_notes],
        :performed_on => (training_file.powermeter_properties.date_time if(training_file.has_performed_on_date_time)) }
    end

end