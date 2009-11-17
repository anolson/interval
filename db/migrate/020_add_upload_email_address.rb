class AddUploadEmailAddress < ActiveRecord::Migration
  def self.up
    add_column :users, :upload_email_address, :string
  end

  def self.down
    remove_column :users, :upload_email_address
  end
end
