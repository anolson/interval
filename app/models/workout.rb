class Workout < ActiveRecord::Base
  belongs_to :user
  has_many :training_files, :dependent => :destroy 
  has_many :comments
  has_many :markers, :order => 'id', :dependent => :destroy 
  has_many :peak_powers, :dependent => :destroy
  
  accepts_nested_attributes_for :training_files
  
  validates_presence_of :name
  
  before_validation :create_empty_name
  
  acts_as_state_machine :initial => :created
  state :created
  state :processing
  state :uploaded
  state :destroying
   
  event :process do
    transitions :to => :processing, :from => :created
  end
  
  event :finish do
    transitions :to => :uploaded, :from => :processing
  end
  
  event :process_destroy do
    transitions :to => :destroying, :from => [:created, :uploaded]
  end
    
  def create_empty_name
    self.name = "New Workout" if self.name.empty?
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

  def self.find_by_created_at_range(range, user_id)
    find_all_by_created_at_and_user_id(range, user_id)
  end

  def self.find_by_date_range(range, user_id)
    find_all_by_performed_on_and_user_id(range, user_id)
  end
    
  def self.find_by_date(year, month, day, user_id)
    date = Date.new(year.to_i, month.to_i, day.to_i)
    find_all_by_performed_on_and_user_id((date..date+1), user_id)
  end
  
  def has_training_files?
    training_files.count > 0
  end
  
  def has_peak_powers?
    peak_powers.count > 0
  end
  
  def belongs_to_user?(user_id)
    self.user.id.eql?(user_id)
  end
  
  def data_points
    if(has_training_files?())
      data_points = self.training_files.first.data_values
    end
  end
  
  def peak_power_data_points
    if(has_peak_powers?)
      self.peak_powers
    end
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
  
  def generate_workout_comments()
    training_file = self.training_files.first
    if training_file.is_srm_file_type? 
      self.notes + " (SRM comment - #{training_file.powermeter_properties.comment})"
    end
  end
  
  def auto_assign(options)
    self.performed_on = option[:performed_on] if options[:perfomed_on]
    self.name = generate_workout_name(options[:auto_assign_name_by]) if options[:auto_assign_name]
    self.notes = generate_workout_comments() if options[:append_srm_comment_to_notes]
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