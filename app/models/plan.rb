class Plan < ActiveRecord::Base
  has_many :subscriptions
  
  def trial_period_end
    (Date.today + 30).strftime("%B %d, %Y")
  end
  
  def paid?
    price > 0
  end
  
  def has_workout_limit? 
    workout_limit > 0
  end

  def price_in_dollars
    (price/100).round
  end
end
