class WorkoutsController < ApplicationController
  layout 'standard'
  before_filter :find_workouts, :only => [:index, :list]
  before_filter :check_that_workout_belongs_to_user, :only => [:show, :graph, :edit, :update, :destroy, :poll]
  before_filter :check_within_plan_limits, :only => [:new, :create]
 
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
    @workout.markers << Marker.create(params[:marker])
    @workout.user = User.find(session[:user])
    
    if @workout.save
      redirect_to(:action => 'index')
    else
      render(:action => 'new')
    end
  end

  def destroy
    @workout.process_destroy!
    #puts "-- #{@workout.state}"
    WorkoutsWorker.async_destroy_workout(:workout_id => params[:id])
    #Workout.destroy(params[:id])
    redirect_to(:action => 'index')
  end
  
  def edit
    render(:layout => false)
  end
  
  def update
    @workout.update_attributes(params[:workout])
    @workout.markers.first.duration = params[:marker]
    @workout.save!
  end
    
  def show
    respond_to do |format|
      format.html
      format.json {        
        @data_points = @workout.data_points
        render :layout => false
      }
    end
  end

  def graph
  end
  
  def poll
  end
  
  
  private
    def find_workouts
      @sort_order = params[:sort_order] || @user.preferences[:sort_order]
      order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
      @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order, :conditions => "state != 'destroying'")
    end
    
    def check_that_workout_belongs_to_user
      @workout = Workout.find(params[:id]) 
      unless @workout.belongs_to_user?(@user.id)
        redirect_to :action => 'index'
      end
    end
end
