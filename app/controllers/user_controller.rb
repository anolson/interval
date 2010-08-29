class UserController < ApplicationController
  skip_before_filter :check_authentication, :except => [:change_password, :delete]
  
  def signin
    if request.post?
      user = User.authenticate(params[:user][:username], params[:user ][:password])
      session[:user] = user.id
      session[:display_name] = user.preferences[:display_name]
      flash[:notice] = "login success"  
      if(session[:intended_params] )
        redirect_to session[:intended_params]
        session[:intended_params] = nil
      else
        redirect_to workouts_path
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end
  
  def signup
     if(request.post?)
      @user = User.new(params[:user])
      if(@user.save!) 
        flash[:notice] = "Thanks for signing up, please signin now."        
        redirect_to :action => "signin"
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end

  def delete
    if(request.post?)
      if(params[:confirm_delete])
        User.destroy(@user)
        signout
      end
    end
  #rescue
  #  flash[:notice] = $!.to_s
  end
  
  def signout
    reset_session
    redirect_to ''
  end

end

