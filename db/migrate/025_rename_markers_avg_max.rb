class RenameMarkersAvgMax < ActiveRecord::Migration
  def self.up
    rename_column :markers, :avg_cadence, :average_cadence
    rename_column :markers, :avg_heartrate, :average_heartrate
    rename_column :markers, :avg_power, :average_power
    rename_column :markers, :avg_speed, :average_speed
    rename_column :markers, :max_cadence, :maximum_cadence
    rename_column :markers, :max_heartrate, :maximum_heartrate
    rename_column :markers, :max_power, :maximum_power
    rename_column :markers, :max_speed, :maximum_speed
  end

  def self.down
    rename_column :markers, :average_cadence, :avg_cadence
    rename_column :markers, :average_heartrate, :avg_heartrate
    rename_column :markers, :average_power, :avg_power
    rename_column :markers, :average_speed, :avg_speed
    rename_column :markers, :maximum_cadence, :max_cadence
    rename_column :markers, :maximum_heartrate, :max_heartrate
    rename_column :markers, :maximum_power, :max_power
    rename_column :markers, :maximum_speed, :max_speed
  end
end
