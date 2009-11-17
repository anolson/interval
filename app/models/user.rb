require 'digest/sha2'
class User < ActiveRecord::Base
  include RandomPronounceableWord
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
  has_one :subscription, :dependent => :destroy 

  
  #TODO remove this after migrating
  belongs_to :plan
  
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
  attr_accessor :password, :old_password
    
  before_create :create_password
  
  def initialize(options = {})
    super(options)
    set_default_preferences
    
    #TODO remove this
    #self.plan = Plan.find_by_name("Free")
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
    if(!user.blank? && user.password_matches?(attributes[:old_password]))
      user.attributes=attributes
      user.create_password
      user.save!
    else
      raise "Old Password Incorrect"
    end
  end
  
  def all_time_best_peak_powers
    PeakPower::DURATIONS.collect { |duration| 
      {:duration => duration, :value => peak_powers.maximum_peak_power(duration)}
    }
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
  
  def upload_email_address
    upload_email_address_value = read_attribute(:upload_email_address)
    if upload_email_address_value.nil?
      upload_email_address_value = generate_upload_email_address
      update_attribute(:upload_email_address, upload_email_address_value)
    end
    upload_email_address_value
  end
  
  def generate_upload_email_address
    "upload+#{random_pronounceable_word}@intervalapp.com"
  end
  
  protected
    def password_required?
      password_hash.blank? || !password.blank?
    end
end

