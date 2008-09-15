class WorkoutsController < ApplicationController
  layout 'standard'
  #skip_before_filter :check_authentication
  #@sharing=false
  
  #before_filter :check_sharing
  
  before_filter :find_workouts, :only => [:index, :list]
  before_filter :check_that_workout_belongs_to_user, :only => [:show, :graph, :edit, :update, :delete]
 
  def index
  end
  
  def list
    render(:partial => 'list', :layout => false)
  end
  
  def new
    @workout = Workout.new
  end
  
  def create
    @workout = Workout.new(params[:workout])   
    @workout.marker = Marker.create(params[:marker])
    @workout.user = User.find(session[:user])
    
    if @workout.save!
      redirect_to(:action => 'index')
    end
  rescue
    render(:action => 'new')
  end

  def delete
    Workout.destroy(params[:id])
    redirect_to(:action => 'index')
  end
  
  def edit
    render(:layout => false)
  end
  
  def update
    @workout.update_attributes(params[:workout])
    @workout.marker.dura = params[:marker]
    @workout.marker.save!
  end
  
  
  def show
    respond_to do |format|
      format.html
      format.json {        
        range_start = params[:begin].nil? && 0 || params[:begin].to_i
        range_end = params[:end].nil? && 0 || params[:end].to_i
        @smoothed_values=@workout.smoothed_data((range_start..range_end))
        render :layout => false
      }
    end
  end
  
  def upload 
    @workout = Workout.new
  end
  
  def upload_file
    user = User.find(session[:user])
    @workout = Workout.new(user.preferences, params[:workout], params[:training_file])
    @workout.user = user
    
    if @workout.save!
      redirect_to(:action => 'index')
    else
      render(:action => 'upload')
    end
  rescue
    render(:action => 'upload')
  end
  
  
  def graph
  end
  
  private
  
    # def check_sharing
    #   @sharing = params[:user].nil? ? false : true
    #   if @sharing
    #      @user = User.find_by_username(params[:user])
    #      if @user.preferences['enable_sharing'].eql?(false)
    #        render :action => 'sharing_not_enabled', :layout => 'application'
    #      end
    #   else
    #     check_authentication
    #     @user = User.find(session[:user])
    #   end
    # end
  
    # def find_workouts
    #   if @sharing
    #     @sort_order = params[:sort_order] || 'name'
    #   else
    #     @sort_order = params[:sort_order] || @user.preferences["sort_order"]
    #   end
    #   order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
    #   #order = "#{@sort_order} DESC"
    #   @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order)
    # end
    
    def find_workouts
      @user = User.find(session[:user])
      @sort_order = params[:sort_order] || @user.preferences["sort_order"]
      order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
      @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order)
    end
    
    def check_that_workout_belongs_to_user
      @workout = Workout.find(params[:id]) 
      unless @workout.belongs_to_user?(session[:user])
        redirect_to :action => 'index'
      end
    end
    


end
