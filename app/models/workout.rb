require 'application_helper'

class Workout < ActiveRecord::Base

  belongs_to :user
  has_many :training_files, :dependent => :destroy 
  has_many :comments
  has_many :markers,  :dependent => :destroy 
  #has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  #def validate_on_create
  #  errors.add("name", "must be unique for given day.")  if Workout.find_by_permalink(self.permalink, self.user.id, self.performed_on.year, self.performed_on.month, self.performed_on.day)
  # end
  
  def initialize(workout={}, file_options={})
    super(workout)
    self.permalink = workout[:name] || ""
  end
    
  def self.per_page 
    5
  end
  
  def tag_string
    self.tags.join(Tag::SEPERATOR)  
  end
  
  def tag_string=(tag_string = "")
    new_tags=[]
    tag_string.split(Tag::SEPERATOR).each do |tag|
      unless(self.tags.include?(tag))
        new_tags << Tag.find_or_create_by_name(tag.strip)
      end
    end
    self.tags = new_tags
  end
  
  def permalink=(name)
    write_attribute(:permalink, name.gsub(" ", "_").gsub(/\W+/, "_").downcase)
  end
  
  def self.find_by_permalink(permalink, user_id, year, month, day)
    date = Date.new(year.to_i, month.to_i, day.to_i)
    find_by_permalink_and_user_id_and_performed_on(permalink, user_id, (date..date+1))
  end
    
  def self.find_by_date(year, month, day, user_id)
    date = Date.new(year.to_i, month.to_i, day.to_i)
    find_all_by_performed_on_and_user_id((date..date+1), user_id)
  end

  def self.find_by_date_range(range, user_id)
    find_all_by_performed_on_and_user_id(range, user_id)
  end
  
  def has_training_files?
    training_files.count > 0
  end
  
  def belongs_to_user?(user_id)
    self.user.id.eql?(user_id)
  end
  
  
  def smoothed_data(range)
    smoothed = {:power => Array.new, :time=> Array.new}
    if(has_training_files?())
      data = self.training_files.first.data_values
      
      data = data.slice(range) if(range.end>range.begin)
      
      puts range.to_s
      
      if data.size < 1000
        size = 1
      else
        size = (data.size / 1000)
      end
      #size = 1 
      data.each_slice(size) { |slice| 
        #smoothed[:power] << a.collect{ |v| v.power}.average 
        smoothed[:power] << slice.first.power
        smoothed[:time] << slice.first.relative_time 
      }
      
    end
    smoothed
  end
  
  def auto_assign(options)
    self.performed_on = options[:performed_on] if options[:performed_on]
    self.name = options[:name] if options[:name]
    self.notes = options[:notes] if options[:notes]
  end
  
end

module Enumerable
  def collect_with_index
    ret = []
    self.each_with_index do |item, index|
      ret.push(yield(item, index))
    end
    ret
  end
end