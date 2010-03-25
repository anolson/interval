class RemovePlans < ActiveRecord::Migration
  def self.up
    drop_table :subscriptions
    drop_table :plans    
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover removing tables(Plans and Subscriptions)."
  end
end
