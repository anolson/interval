class DestroyWorkoutJob < Struct.new(:workout_id)
  def perform
    Workout.destroy(workout_id)
  end
end