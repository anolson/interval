class SiteController < ApplicationController

  skip_before_filter :check_authentication
  def index
  end
  
  def privacy_policy
  end
  
  def plans
    @plans = Plan.find(:all, :conditions => {:public => true})
    @user && @current_plan = @user.subscription.plan
  end
  
  def terms
  end
  
  def support
  end
  
  def tour
  end
end
