require "migration_helpers"
class CreatePeakPowers < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :peak_powers do |t|
      t.column :duration,   :integer, :default => 0
      t.column :start,      :integer, :default => 0
      t.column :value,      :float,   :default => 0
      t.column :workout_id, :integer, :default => 0
    end
  end
  
  foreign_key(:peak_powers, :workout_id, :workouts)
  foreign_key(:peak_powers, :user_id, :users)

  def self.down
    drop_table :peak_powers
  end
end
