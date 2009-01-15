require "migration_helpers" 
class CreatePlans < ActiveRecord::Migration 
  extend MigrationHelpers
  def self.up
    create_table :plans do |t|
      t.column :name,           :string
      t.column :description,    :text
      t.column :workout_limit,  :integer 
      t.column :price,          :float
      t.column :enabled,        :boolean
      t.timestamps
    end
    
    Plan.create :name => "Free", :description => "Free plan that is limited to 10 Workouts.", :workout_limit => 10, :price => 0, :enabled => true
    Plan.create :name => "Basic", :description => "Basic plan, 2 workouts/week.", :workout_limit => 0, :price => 400, :enabled => true
    Plan.create :name => "Plus", :description => "Plus plan, 5 workouts/week.", :workout_limit => 0, :price => 700, :enabled => true
    Plan.create :name => "Pro", :description => "Unlimited Account.", :workout_limit => 0, :price => 1000, :enabled => true
    
    add_column :users, :plan_id, :integer
    foreign_key(:users, :plan_id, :plans)
  end

  def self.down
    drop_table :plans
    remove_column :users, :plan_id
  end
end
