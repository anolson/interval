require "migration_helpers" 
class CreateRoles < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :roles do |t|
      t.column :name,           :string
      t.column :description,    :text
    end
    
    Role.create :name => "admin", :description => "Role given to all admins"
    Role.create :name => "athlete", :description => "Role given to all athletes"
    
    create_table :roles_users do |t|
      t.column :user_id,    :integer
      t.column :role_id,    :integer
    end
    
    foreign_key(:roles_users, :user_id, :users)
    foreign_key(:roles_users, :role_id, :roles)
    
    create_table :rights do |t|
      t.column :controller, :string
      t.column :action,     :string
      t.column :role_id,    :integer
    end
    
    foreign_key(:rights, :role_id, :roles)
  end

  def self.down
    drop_table :rights
    drop_table :roles_users
    drop_table :roles
  end
end
