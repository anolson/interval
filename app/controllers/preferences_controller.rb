class PreferencesController < ApplicationController

  before_filter :find_user
  
  def index
    #if params[:preferences]['parse_srm_comment'].nil? 
      #params[:preferences]['parse_srm_comment'] = false
    #end
    #
    save_preferences
  end
  
  
  def interface
    save_preferences
  end
  
  private 
    def find_user
       @user = User.find(session[:user])
    end
  
    def save_preferences
      if request.post?
        @user.update_attributes(params[:user])
        params[:preferences]['enable_sharing'] = false if params[:preferences]['enable_sharing'].nil? 
        @user.update_attribute_with_validation_skipping(:preferences, params[:preferences])
      end
    end
      
  
end
