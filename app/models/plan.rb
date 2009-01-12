class Plan < ActiveRecord::Base
  has_many :users
  
  def trial_period_end
    (Date.today + 30).strftime("%B %d, %Y")
  end
end
