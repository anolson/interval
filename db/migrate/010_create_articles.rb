class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.text :body         
      t.string :category
      t.string :permalink
      t.integer :number_of_views, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
