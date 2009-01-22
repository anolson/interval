class UserController < ApplicationController
  skip_before_filter :check_authentication, :except => [:change_password, :delete, :update, :update_plan]
  ssl_required :signin, :signup, :change_password, :update, :update_plan
  
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
    @plan = Plan.find_by_name(params[:plan].capitalize)
    if(request.post?)
      @user = User.new(params[:user])

      @subscription = Subscription.new(:plan => @plan, :credit_card => params[:credit_card])
      @credit_card = @subscription.credit_card
      if(@subscription.valid? && @user.valid?) 
        @user.subscription = @subscription
        if(@user.save!)
          @user.subscription.subscribe
          flash[:notice] = "account created, please signin"        
          redirect_to :action => "signin"
        end
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end

  def delete
    if(request.post?)
      if(params[:confirm_delete])
        @user.subscription.cancel
        User.destroy(@user)
        signout
      end
    end
  rescue
    flash[:notice] = $!.to_s
  end
  

  def update_plan
    @plan = Plan.find_by_name(params[:plan].capitalize)
    if(request.post?)
      if(Subscription.is_within_limits?(@user, @plan))
        @user.subscription.credit_card = params[:credit_card]
        @credit_card = @user.subscription.credit_card
        if(@user.subscription.valid?)
          if(@user.save!)
            @user.subscription.change(@plan)
            flash[:notice] = "account updated"        
            redirect_to :controller => 'site', :action => 'plans'
          end
        end
      end
    end
  rescue
   flash[:notice] = $!.to_s
  end
  
  
  def update
    if(request.post?)
      @user.subscription.credit_card = params[:credit_card]
      @credit_card = @user.subscription.credit_card
      if(@user.subscription.valid?)
        if(@user.save!)
          @user.subscription.change(@user.subscription.plan)
          flash[:notice] = "account updated"        
          redirect_to :controller => 'preferences'
        end
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

