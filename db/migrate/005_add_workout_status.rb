class AddWorkoutStatus < ActiveRecord::Migration
  def self.up
    add_column :workouts, :state, :string, :default => "created"
  end

  def self.down
    remove_column :workouts, :state
  end
end
