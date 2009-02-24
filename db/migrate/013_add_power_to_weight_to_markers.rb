class AddPowerToWeightToMarkers < ActiveRecord::Migration
  def self.up
    add_column :markers, :average_power_to_weight, :float, :default => 0
    add_column :markers, :maximum_power_to_weight, :float, :default => 0
  end

  def self.down
    remove_column :markers, :average_power_to_weight
    remove_column :markers, :maximum_power_to_weight
   end
end
