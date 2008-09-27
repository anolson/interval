require 'digest/sha2'
class User < ActiveRecord::Base
  DEFAULT_PREFERENCES = {
    "display_name" => "", 
    "parse_srm_comment" => false, 
    "sort_order" => "name" }
  
  has_many :workouts
  belongs_to :plan
  serialize :preferences, Hash
  
    
  attr_accessor :password, :old_password
  
  validates_presence_of :username
  validates_presence_of :email
  validates_presence_of :password, :password_confirmation, :if => :password_required?
  validates_acceptance_of :agreed_to_terms
  
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_confirmation_of :password, :if => :password_required?
  
  attr_accessible :username, :email, :password, :password_confirmation, :preferences
    
  before_create :create_password
  
  def initialize(options = {})
    super(options)
    self.preferences = User::DEFAULT_PREFERENCES
    self.preferences["display_name"]=self.username
    self.plan = Plan.find_by_name("Free")
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
  
  protected
    def password_required?
      password_hash.blank? || !password.blank?
    end
end

