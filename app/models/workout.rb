class Workout < ActiveRecord::Base
  belongs_to :user
  has_many :training_files, :dependent => :destroy 
  has_many :comments
  has_many :markers, :order => 'id', :dependent => :destroy 
  has_many :peak_powers, :order=> 'id', :dependent => :destroy
  
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
    
    
  def self.create_from_email(message)
    mail = TMail::Mail.parse(message)
    
    unless(mail.attachments.blank?)
      upload_email_secret = mail.to.first.split('@').first.split('+').second
      if(upload_email_secret)
        user = User.find_by_upload_email_secret upload_email_secret    
        params = {
          :name => mail.subject,
          :performed_on => mail.date,
          :notes => mail.body_plain.strip,
          :training_files_attributes => [{:payload => mail.attachments.first}]
        } 
        workout = Workout.new params
        workout.user = user
        
        if workout.save
          workout.process!
          WorkoutsWorker.async_process_workout(:workout_id => workout.id)
        end
      end
    end
  end  
  
  def create_empty_name
    self.name = "New Workout" if self.name.empty?
  end
    
  def self.per_page 
    5
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
  
  def self.process(id)
    workout = Workout.find(id)

    training_file = workout.training_files.first
    training_file.parse_file_data
    training_file.save

    workout.markers << training_file.markers
    workout.peak_powers << training_file.peak_powers.collect {|p| PeakPower.new(p) }
    workout.auto_assign workout.auto_assign_options(workout.user, training_file)
    workout.auto_assign training_file.auto_assign_options
    workout.save
    workout.finish!
  end
  
  def auto_assign(options)
    self.performed_on = options[:performed_on] if options[:performed_on]
    self.name = generate_workout_name(options[:auto_assign_name_by]) if options[:auto_assign_name]
    self.notes = generate_workout_comments() if options[:append_srm_comment_to_notes]
  end
  
  def auto_assign_options(user, training_file)
    user.auto_assign_options.merge(training_file.auto_assign_options)
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