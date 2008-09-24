class TrainingFileWorker < Workling::Base
  def parse_workout(options)
    user = User.find(options[:user_id])
    workout = Workout.new(options[:params][:workout], options[:params][:training_file], user.preferences)
    workout.user = user
    workout.status = "finished."
    workout.save!
  end
end