class AddTimesToDataValues < ActiveRecord::Migration
  def self.up
    add_column :data_values, :time, :integer, :default => 0
    add_column :data_values, :time_with_pauses, :integer, :default => 0
    add_column :data_values, :time_of_day, :integer, :default => 0
  end

  def self.down
    remove_column :data_values, :time
    remove_column :data_values, :time_with_pauses
    remove_column :data_values, :time_of_day
  end
end
