class AddIndices < ActiveRecord::Migration
  def self.up
    if(ENV["RAILS_ENV"] == "production")
      add_index(:workouts, :user_id)
      add_index(:training_files, :workout_id)
      add_index(:markers, :workout_id)
      add_index(:peak_powers, :workout_id)
    end
  end
  
  def self.down
    if(ENV["RAILS_ENV"] == "production")
      remove_index(:workouts, :user_id)
      remove_index(:training_files, :workout_id)
      remove_index(:markers, :workout_id)
      remove_index(:peak_powers, :workout_id)
    end
  end
end
