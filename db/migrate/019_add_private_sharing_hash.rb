class AddPrivateSharingHash < ActiveRecord::Migration
  def self.up
    add_column :users, :private_sharing_hash, :string
  end

  def self.down
    remove_column :users, :private_sharing_hash
  end
end
