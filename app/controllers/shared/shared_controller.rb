class Shared::SharedController < ApplicationController  
  skip_before_filter :check_authentication
  
  private
  def check_sharing
    if(params[:user])
      check_public_sharing
    else
      check_private_sharing
      @private=true
    end
  end
  
  def check_public_sharing
    @user = User.find_by_username(params[:user]) or raise ActiveRecord::RecordNotFound
    if(@user.preferences[:share_workouts_publicly].nil? || @user.preferences[:enable_sharing].nil?)
      render :template => 'shared/sharing_not_enabled', :layout => 'application'
    end
  end
  
  def check_private_sharing
    @user = User.find_by_private_sharing_hash(params[:hash]) or raise ActiveRecord::RecordNotFound
    if @user.preferences[:enable_sharing].nil?
      render :template => 'shared/sharing_not_enabled', :layout => 'application' 
    end
  end
  
  def find_workout
    if(params[:id])
      @workout = Workout.find(params[:id]) 
    elsif(params[:workout_id])
      @workout = Workout.find(params[:workout_id]) 
    else
      @workout = Workout.find(params[:private_workout_id]) 
    end
  
    
  end

  def find_workouts
    @sort_order = params[:sort_order] || 'name'
    order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
    @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order, :conditions => { :state => ["created", "uploaded"], :shared => true})
  end
  
  def check_that_workout_belongs_to_user
    if(!@workout.belongs_to_user?(@user.id) or !@workout.shared)
        redirect_to :action => 'index'
    end
  end
      
end

 