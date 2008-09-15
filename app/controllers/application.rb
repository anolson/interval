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
end
