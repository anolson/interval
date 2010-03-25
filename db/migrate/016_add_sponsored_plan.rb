class AddSponsoredPlan < ActiveRecord::Migration
  def self.up
    Plan.create :name => "Sponsored", :description => "Sponsored plan, umlimited.", :workout_limit => 0, :storage_limit => 5368709120, :price => 700, :enabled => true, :public => false 
  end
  
  def self.down
  end
end
