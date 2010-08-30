class UsersController < ApplicationController
  skip_before_filter :check_authentication, :only => [:new, :create]
  
  def new
    @user = User.new
  end
  
  def create     
    @user = User.new(params[:user])
    if(@user.save) 
      flash[:notice] = "Thanks for signing up, please signin now."        
      redirect_to signin_path
    else
      render :action => 'new'
    end
  end

  def destroy
    if(params[:confirm_delete]) #destroy the current user in the session
      @user.destroy
      reset_session
      redirect_to root_path
    else
      render new_user_path
    end
  end
  
  def confirm_destroy
  end

end

