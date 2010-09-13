class ProcessWorkoutJob < Struct.new(:workout_id)
  def perform
    Workout.process(workout_id)
  end
end