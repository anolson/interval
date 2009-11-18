class WorkoutsWorker < Workling::Base
  def process_workout(options)
    workout = Workout.find(options[:workout_id])
    logger.info("Processing Workout -- ID: #{workout.id}")
    
    training_file = workout.training_files.first
    training_file.parse_file_data
    training_file.save
    
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
    def auto_assign_options(user, file)
      auto_assign_options_for_user(user).merge(auto_assign_options_for_file(file))
    end
  
    def auto_assign_options_for_user(user)
      options = { 
        :auto_assign_name => user.preferences[:auto_assign_workout_name],
        :auto_assign_name_by => user.preferences[:auto_assign_workout_name_by],
        :append_srm_comment_to_notes => user.preferences[:append_srm_comment_to_notes] }
    end
    
    def auto_assign_options_for_file(file)
      if(file.has_performed_on_date_time?)
        { :performed_on => file.powermeter_properties.date_time }
      end
    end

end