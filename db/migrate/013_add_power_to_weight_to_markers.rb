class AddPowerToWeightToMarkers < ActiveRecord::Migration
  def self.up
    add_column :markers, :average_power_to_weight, :float
    add_column :markers, :maximum_power_to_weight, :float
  end

  def self.down
    remove_column :markers, :average_power_to_weight
    remove_column :markers, :maximum_power_to_weight
   end
end
