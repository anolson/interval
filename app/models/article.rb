class Article < ActiveRecord::Base
  CATEGORIES = ["Support", "Blog"]
  
  def initialize(options = {})
    super options
    self.permalink = options[:title]
  end

  def permalink=(name = "")
    name && write_attribute(:permalink, name.gsub(/\W+/, " ").strip.gsub(" ", "_").downcase)
  end

end


