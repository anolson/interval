class PreferencesController < ApplicationController
  layout 'standard'
  
  def show
  end
  
  def update
    @user.update_attributes(params[:user])
    redirect_to preferences_path
  end
  
  def reset_sharing_links
    @user.update_attribute(:private_sharing_hash, @user.generate_private_sharing_hash)
    redirect_to preferences_path
  end
  
  def reset_upload_address
    @user.update_attribute(:upload_email_secret, @user.generate_upload_email_secret)
    redirect_to preferences_path
  end
    
end
