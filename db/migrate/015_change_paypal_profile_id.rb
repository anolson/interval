class ChangePaypalProfileId < ActiveRecord::Migration
  def self.up
    rename_column :subscriptions, :paypal_profile_idcd, :paypal_profile_id
  end

  def self.down
  end
end
