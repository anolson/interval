require "migration_helpers"
class CreateSubscriptions < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :subscriptions do |t|
      t.string :paypal_profile_id
      t.integer :plan_id
      t.integer :user_id
      t.timestamps
    end
    
    foreign_key(:subscription, :user_id, :users)
    foreign_key(:subscription, :plan_id, :plan)
    #TODO remove after migrate in prod
    User.reset_column_information
    User.find(:all).each { |u|
      u.subscription = Subscription.new(:plan => u.plan)
      u.save!
    }
    remove_column :users, :plan_id

  end

  def self.down
    add_column :users, :plan_id, :integer
    User.reset_column_information
    
    #TODO remove after migrate in prod
    User.find(:all).each { |u|
      u.plan = u.subscription.plan
      u.save!
    }
    drop_table :subscriptions
  end
end
