class UserController < ApplicationController
  skip_before_filter :check_authentication, :except => :change_password
  ssl_required :signin, :signup, :change_password
  
  def change_password
    if request.post?
      User.change_password(session[:user], params[:user])
      flash[:notice] = 'Password changed, please signin.'
      session[:user] = nil
      redirect_to :action => 'signin'
    end
  rescue
    flash[:notice] = $!.to_s 
  end
  
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
        redirect_to :controller => "workouts", :action => user.preferences[:workout_view]
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end
  
  def signup
    @plan = Plan.find_by_name(params[:plan])
    if(request.post?)
      @user = User.new(params[:user])
      if(@user.save!)
        flash[:notice] = "account created, please signin"        
        redirect_to :action => "signin"
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end
  
  def signout
    reset_session
    redirect_to ''
  end

end

