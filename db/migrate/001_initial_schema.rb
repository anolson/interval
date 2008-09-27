require "migration_helpers" 

class InitialSchema < ActiveRecord::Migration
    extend MigrationHelpers

  def self.up
    create_table :users do |table|
      table.column :created_at,     :datetime
      table.column :disabled,       :boolean,  :default => false
      table.column :last_login,     :datetime
      table.column :password_hash,  :string
      table.column :password_salt,  :string
      table.column :username,       :string
      table.column :terms_of_service, :boolean
    end
    
    create_table :workouts do |table|
      table.column :created_at, :datetime
      table.column :name, :string
      table.column :notes, :text
      table.column :performed_on, :datetime
      table.column :permalink, :string
      table.column :uploaded, :boolean, :default => false
      table.column :user_id, :integer
    end
    
    #foreign_key(:workouts, :user_id, :users)
    
    create_table :comments do |table|
      table.column :body,       :text
      table.column :created_at, :datetime
      table.column :user_id,    :integer
      table.column :workout_id,    :integer
    end
    
    #foreign_key(:comments, :workout_id, :workouts)
    
    create_table :training_files do |table|
      table.column :created_at, :datetime 
      table.column :filename, :string
      table.column :payload, :binary
      table.column :powermeter_properties, :text
      table.column :workout_id, :integer
    end
    
    #foreign_key(:training_files, :workout_id, :workouts)
    
    create_table :data_values do |table|
      table.column :training_file_id, :integer
      table.column :relative_time, :integer
      table.column :absolute_time, :integer
      table.column :power, :integer
      table.column :cadence, :integer
      table.column :heartrate, :integer
      table.column :speed, :float
      table.column :distance, :float
    end
    
    #foreign_key(:data_values, :training_file_id, :training_files)    
    add_index(:data_values, :training_file_id)
      
    create_table :markers do |table|
      table.column :active, :boolean, :default => true
      table.column :avg_cadence, :integer, :default => 0
      table.column :avg_heartrate, :integer, :default => 0
      table.column :avg_power, :integer, :default => 0
      table.column :avg_speed, :float, :default => 0
      table.column :comment, :string    
      table.column :duration_seconds, :integer, :default => 0
      table.column :distance, :float, :default => 0
      table.column :end, :integer
      table.column :energy, :integer , :default => 0
      table.column :max_cadence, :integer, :default => 0
      table.column :max_heartrate, :integer, :default => 0
      table.column :max_power, :integer, :default => 0
      table.column :max_speed, :float, :default => 0
      table.column :start, :integer      
      table.column :workout_id, :integer
    end
    
    #foreign_key(:markers, :workout_id, :workouts)
  
  end
  

  def self.down
    drop_table :data_values
    drop_table :markers
    drop_table :training_files
    drop_table :comments
    drop_table :workouts
    drop_table :users
  end
end
