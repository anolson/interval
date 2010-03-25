class AddUploadEmailSecret < ActiveRecord::Migration
  def self.up
    add_column :users, :upload_email_secret, :string
  end

  def self.down
    remove_column :users, :upload_email_secret
  end
end
