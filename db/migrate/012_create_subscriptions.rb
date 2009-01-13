class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :paypal_profile_id
      t.integer :plan_id
      t.integer :user_id
      t.timestamps
    end
    
    #foreign_key(:subscription, :user_id, :users)
    #foreign_key(:subscription, :plan_id, :plan)
    #TODO remove after migrate in prod
    User.reset_column_information
    User.find(:all).each { |user|
      user.subscription = Subscription.new(:plan => user.plan)
      user.save
    }
    remove_column :users, :plan_id

  end

  def self.down
    add_column :users, :plan_id, :integer
    User.reset_column_information
    
    #TODO remove after migrate in prod
    User.find(:all).each { |user|
      user.plan = user.subscription.plan
      user.save
    }
    remove_column :users, :subscription_id
    drop_table :subscriptions
  end
end
