class AddCogganPower < ActiveRecord::Migration
  def self.up
    add_column :markers, :normalized_power, :integer, :default => 0
  end

  def self.down
    remove_column :markers, :normalized_power
   end
end
