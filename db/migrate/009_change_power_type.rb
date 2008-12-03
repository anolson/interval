class ChangePowerType < ActiveRecord::Migration
  def self.up
    change_column :data_values, :power, :float
  end

  def self.down
    change_column :data_values, :power, :integer
   end
end