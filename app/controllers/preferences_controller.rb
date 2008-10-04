class PreferencesController < ApplicationController

  before_filter :find_user
  
  def index
    save_preferences
  end
  
  
  def plan
    @plans = Plan.find(:all)
  end
  
  private 
    def find_user
       @user = User.find(session[:user])
    end
  
    def save_preferences
      if request.post?
        @user.update_attributes(params[:user])
        params[:preferences].symbolize_keys!
        params[:preferences][:enable_sharing] = false if params[:preferences][:enable_sharing].nil? 
        @user.update_attribute_with_validation_skipping(:preferences, params[:preferences])
      end
    end
      
  
end
