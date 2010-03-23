class UserController < ApplicationController
  skip_before_filter :check_authentication, :except => [:change_password, :delete, :update]
  ssl_required :signin, :signup, :change_password, :update
  
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
  
  def reset_sharing_links
    user = User.find session[:user]
    user.update_attribute(:private_sharing_hash, user.generate_private_sharing_hash)
    redirect_to :controller => 'preferences'
  end
  
  def reset_upload_address
    user = User.find session[:user]
    user.update_attribute(:upload_email_secret, user.generate_upload_email_secret)
    redirect_to :controller => 'preferences'
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

