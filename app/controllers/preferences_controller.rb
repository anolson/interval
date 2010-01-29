class PreferencesController < ApplicationController
  layout 'standard'
    
  def index
    save_preferences
  end
    
  private   
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
