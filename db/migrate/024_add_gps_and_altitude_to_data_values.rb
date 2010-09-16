class AddGpsAndAltitudeToDataValues < ActiveRecord::Migration
  def self.up
    add_column :data_values, :altitude, :float, :default => 0.0
    add_column :data_values, :longitude, :float, :default => 0.0
    add_column :data_values, :latitude, :float, :default => 0.0
  end

  def self.down
    remove_column :data_values, :altitude
    remove_column :data_values, :longitude
    remove_column :data_values, :latitude
  end
end
