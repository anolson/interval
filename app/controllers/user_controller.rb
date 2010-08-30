class UserController < ApplicationController
  skip_before_filter :check_authentication, :except => [:delete]

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
        reset_session
        redirect_to root_path
      end
    end
  #rescue
  #  flash[:notice] = $!.to_s
  end
  


end

