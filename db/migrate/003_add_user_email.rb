class AddUserEmail < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :text
  end

  def self.down
    remove_column :users, :email
  end
end
