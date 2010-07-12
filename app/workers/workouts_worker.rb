class WorkoutsWorker < Workling::Base
  def process_workout(options)
    Workout.process(options[:workout_id])
  end
  
  def destroy_workout(options)
    Workout.destroy(options[:workout_id])
  end
end