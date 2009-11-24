class RemoveRolesUsersId < ActiveRecord::Migration
  def self.up
    remove_column :roles_users, :id
    add_index :roles_users, [ :role_id, :user_id ], :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
