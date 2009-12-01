class PreferencesController < ApplicationController
  layout 'standard'
    
  def index
    @subscription_details = @user.subscription.details
    save_preferences
  end
  
  def plan
    @plans = Plan.find(:all)    
  end
    
  private 
    #def find_user
    #   @user = User.find(session[:user])
    #end
  
    def save_preferences
      if request.post?
        @user.update_attributes(params[:user])
        params[:preferences].symbolize_keys!
        params[:preferences][:enable_sharing] = false if params[:preferences][:enable_sharing].nil? 
        params[:preferences][:share_workouts_publicly] = false if params[:preferences][:share_workouts_publicly].nil? 
        @user.update_attribute(:preferences, params[:preferences])
      end
    end
end
