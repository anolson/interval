class Tag < ActiveRecord::Base
  has_and_belongs_to_many :workouts
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  SEPERATOR = ', '
  
  def to_s()
    return name;
  end
  
end
