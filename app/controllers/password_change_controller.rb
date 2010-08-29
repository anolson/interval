class PasswordChangeController < ApplicationController
  def new
  end
  
  def create
    User.change_password(@user.id, params[:user])
    reset_session
    flash[:notice] = 'Password changed, please signin.'
    redirect_to signin_path
  rescue
    flash[:notice] = $!.to_s 
    redirect_to new_password_change_path
  end
end
