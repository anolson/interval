# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :check_authentication
  
  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_interval_session_id'
  
  def check_authentication
    unless session[:user]
      session[:intended_params] = params
      redirect_to(signin_url)
    end
  end
  
  def rescue_action_in_public(exception) 
    if exception.is_a? ActiveRecord::RecordNotFound 
      render :file => "#{RAILS_ROOT}/public/404.html", 
             :status => '404 Not Found' 
    else 
      super 
    end 
  end
  
  def check_within_plan_limits
    if(@user.workouts.size >= @user.plan.workout_limit)
      render :action => 'limit_reached', :layout => 'application'
      #@limit_reached = true
    end
  end
  
  def find_user
    @user = User.find(session[:user])
  end
  
  
end
