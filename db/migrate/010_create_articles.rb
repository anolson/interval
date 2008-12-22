class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.text :body         
      t.string :category
      t.integer :number_of_views
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
