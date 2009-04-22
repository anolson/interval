class AddIndividualSharing < ActiveRecord::Migration
  def self.up
    add_column :workouts, :shared, :boolean, :default => true
  end

  def self.down
    remove_column :workouts, :shared
  end
end
