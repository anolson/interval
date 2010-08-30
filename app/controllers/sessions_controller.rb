class SessionsController < ApplicationController
  skip_before_filter :check_authentication
  
  def new
  end
  
  def create
    user = User.authenticate(params[:user][:username], params[:user ][:password])
    setup_session(user)
    redirect_to_intended_path
  rescue
    flash[:notice] = $!.to_s
    redirect_to signin_path
  end
  
  def destroy
    reset_session
    redirect_to root_path
  end
  
  private
  
  def setup_session(user)
    session[:user] = user.id
    session[:display_name] = user.preferences[:display_name]
  end
  
  def redirect_to_intended_path
    if(session[:intended_params] )
      redirect_to session[:intended_params]
      session[:intended_params] = nil
    else
      redirect_to workouts_path
    end
  end
  
end
