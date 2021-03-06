require 'digest/sha2'
class User < ActiveRecord::Base
  include RandomPronounceableString
  DEFAULT_PREFERENCES = {
    :display_name => "", 
    :parse_srm_comment => false, 
    :sort_order => "name", 
    :auto_assign_workout_name => true, 
    :auto_assign_workout_name_by => 'filename',
    :units_of_measurement => 'english', 
    :graph => {:power => true}}
  
  has_many :workouts
  has_and_belongs_to_many :roles
  
  serialize :preferences, Hash
  has_many :peak_powers, :through => :workouts
  
  validates_presence_of :username
  validates_format_of :username, :with => /\A\w[\w\.\-_@]+\z/, :on => :create
  validates_presence_of :email
  validates_presence_of :password, :password_confirmation, :if => :password_required?
  validates_acceptance_of :terms_of_service, :allow_nil => false, :accept => true
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_confirmation_of :password, :if => :password_required?
  
  attr_accessible :username, :email, :password, :password_confirmation, :preferences, :plan, :terms_of_service
  attr_accessor :password, :current_password
    
  before_create :create_password
  
  def initialize(options = {})
    super(options)
    set_default_preferences
  end
  
  def set_default_preferences
    self.preferences = User::DEFAULT_PREFERENCES
    self.preferences[:display_name]=self.username
  end
  
  def create_password
    self.password_salt = generate_salt
    self.password_hash = hash_password(self.password, self.password_salt)
  end
  
  def generate_salt 
    [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
  
  def hash_password(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end
  
  def password_matches?(password)
    hash_password(password, self.password_salt) == password_hash
  end
  
  def self.authenticate(username, password)
    user = User.find_by_username(username)
    if user.blank? || !user.password_matches?(password)
      raise "Username or Password Invalid"
    else 
      return user
    end
  end
  
  def self.change_password(id, attributes = {}) 
    user=User.find(id)
    if(!user.blank? && user.password_matches?(attributes[:current_password]))
      user.attributes=attributes
      user.create_password
      user.save!
    else
      raise "Old Password Incorrect"
    end
  end
  
  def all_time_best_peak_powers
    if(!peak_powers.empty?)
      PeakPower::DURATIONS.collect { |duration| 
        {:duration => duration, :value => peak_powers.maximum_peak_power(duration)}
      }
    else
      {}
    end
  end
  
  def private_sharing_hash 
    private_sharing_hash_value = read_attribute(:private_sharing_hash)
    if(private_sharing_hash_value.nil?)
      private_sharing_hash_value = generate_private_sharing_hash
      update_attribute(:private_sharing_hash, private_sharing_hash_value)
    end
    private_sharing_hash_value
  end
  
  def generate_private_sharing_hash
    Digest::MD5.hexdigest([Array.new(6) { rand(256).chr}.join].pack('m').chomp)
  end
  
  def upload_email_secret
    upload_email_secret_value = read_attribute(:upload_email_secret)
    if upload_email_secret_value.nil?
      upload_email_secret_value = generate_upload_email_secret
      update_attribute(:upload_email_secret, upload_email_secret_value)
    end
    upload_email_secret_value
  end
  
  def generate_upload_email_secret
    random_pronounceable_string + (100 + rand(899)).to_s
  end
  
  def auto_assign_options
    { :auto_assign_name => self.preferences[:auto_assign_workout_name],
      :auto_assign_name_by => self.preferences[:auto_assign_workout_name_by],
      :append_srm_comment_to_notes => self.preferences[:append_srm_comment_to_notes] }
  end
  
  protected
    def password_required?
      password_hash.blank? || !password.blank?
    end
end

