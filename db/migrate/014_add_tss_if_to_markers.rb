class AddTssIfToMarkers < ActiveRecord::Migration
  def self.up
    add_column :markers, :training_stress_score, :integer
    add_column :markers, :intensity_factor, :float
  end

  def self.down
    remove_column :markers, :training_stress_score
    remove_column :markers, :intensity_factor
   end
end
