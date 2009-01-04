class AddTorque < ActiveRecord::Migration
  def self.up
    add_column :data_values, :torque, :float, :default => 0
  end

  def self.down
    remove_column :data_values, :torque
  end
end
