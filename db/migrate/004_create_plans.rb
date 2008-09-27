require "migration_helpers" 
class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.column :name,           :string
      t.column :description,    :text
      t.column :workout_limit,  :integer 
      t.column :price,          :float
      t.column :enabled,        :boolean
      t.timestamps
    end
    
    Plan.create :name => "Free", :description => "The Free plan that is limited to 10 Workouts.", :workout_limit => 10, :price => 0, :enabled => true
    Plan.create :name => "Athlete Plus", :description => "Unlimited Account.", :workout_limit => 0, :price => 6.99, :enabled => false
    
    add_column :users, :plan_id, :integer
    foreign_key(:users, :plan_id, :plans)
  end

  def self.down
    drop_table :plans
    remove_column :users, :plan_id
  end
end
