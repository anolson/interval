class AddWorkoutStatus < ActiveRecord::Migration
  def self.up
    add_column :workouts, :status, :string
  end

  def self.down
    remove_column :workouts, :status
  end
end
