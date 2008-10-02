class WorkoutsWorker < Workling::Base
  def parse_workout(options)
    #user = User.find(options[:user_id])
    #workout = Workout.new(options[:params][:workout], options[:params][:training_file], user.preferences)
    #workout.user = user
    #workout.status = "finished."
    #workout.save!
    
    puts "***********************************"
    puts "Calling workout workter."
    workout = Workout.find(options[:workout_id])
    training_file = workout.training_files.first
    training_file.parse_file_data
    workout.markers << training_file.markers
    
    if training_file.is_srm_file_type?
      options = {}
      options[:performed_on] = training_file.performed_on
      workout.auto_assign options
    end
    
    workout.save
  end
end