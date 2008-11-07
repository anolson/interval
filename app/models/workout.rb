require 'application_helper'

class Workout < ActiveRecord::Base

  belongs_to :user
  has_many :training_files, :dependent => :destroy 
  has_many :comments
  has_many :markers,  :dependent => :destroy 
  #has_and_belongs_to_many :tags
  
  validates_presence_of :name
  
  
  acts_as_state_machine :initial => :created

  state :created
  state :processing
  state :uploaded
   
  event :process do
    transitions :to => :processing, :from => :created
  end
  
  event :finish do
    transitions :to => :uploaded, :from => :processing
  end
  
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
      
      if(range.end>0)
        power_series = data.slice(range).collect_with_index{|v, i| [i, v.power]}
        time_series = data.slice(range).collect_with_index{|v, i| [i, Time.at(v.relative_time).utc.strftime("%k:%M:%S")]}
      else
        power_series = data.collect_with_index{|v, i| [i, v.power]}
        time_series = data.collect_with_index{|v, i| [i, Time.at(v.relative_time).utc.strftime("%k:%M:%S")]}
      end
      
      size = (power_series.size < 1000) && 1 || (power_series.size / 1000)
      size = 1
      puts size
      power_series.each_slice(size) { |s| smoothed[:power] << s[0] }
      time_series.each_slice(size) { |s| smoothed[:time] << s[0] }
    end
    smoothed
  end
  
  def generate_workout_name(generate_by)
    training_file = self.training_files.first
    if training_file.is_srm_file_type? 
      if generate_by.eql?('filename')
        training_file.file_basename
      else
        training_file.powermeter_properties.comment.gsub(/^[\w]*\s/, '')        
      end
    else
      training_file.file_basename if generate_by.eql?('filename')
    end
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