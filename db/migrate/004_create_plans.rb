require "migration_helpers" 
class CreatePlans < ActiveRecord::Migration 
  extend MigrationHelpers
  def self.up
    create_table :plans do |t|
      t.column :name,           :string
      t.column :description,    :text
      t.column :workout_limit,  :integer
      t.column :limit_by,       :string
      t.column :storage_limit,  :integer, :limit => 8
      t.column :price,          :float
      t.column :enabled,        :boolean
      t.column :public,         :boolean
      t.timestamps
    end
    
    create_table :subscriptions do |t|
      t.string :paypal_profile_idcd
      t.integer :plan_id
      t.integer :user_id
      t.timestamps
    end
    
    Plan.create :name => "Comp", :description => "Comp plan, umlimited, not billed.", :workout_limit => 0, :storage_limit => 5368709120, :price => 0, :enabled => true, :public => false
    Plan.create :name => "Free", :description => "Free plan that is limited to 10 Workouts.", :workout_limit => 10, :limit_by => 'total', :storage_limit => 20971520, :price => 0, :enabled => true, :public => true
    Plan.create :name => "Basic", :description => "Basic plan, 2 workouts/week.", :workout_limit => 2, :limit_by => 'week', :storage_limit => 524288000, :price => 400, :enabled => true, :public => true
    Plan.create :name => "Plus", :description => "Plus plan, 5 workouts/week.", :workout_limit => 5, :limit_by => 'week', :storage_limit => 2147483648, :price => 700, :enabled => true, :public => true
    Plan.create :name => "Pro", :description => "Unlimited Account.", :workout_limit => 0, :price => 1000, :storage_limit => 5368709120, :enabled => true, :public => true
    
    foreign_key(:subscriptions, :user_id, :users)
    foreign_key(:subscriptions, :plan_id, :plan)
  end

  def self.down
    drop_table :subscriptions
    drop_table :plans
  end
end
