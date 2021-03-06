class WorkoutsController < ApplicationController
  layout 'standard'

  before_filter :find_workouts, :only => [:index]
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  before_filter :check_that_workout_belongs_to_user, :only => [:show, :edit, :update, :destroy]
 
  def index
    respond_to do |format|
      format.html {
        @workout_count = @user.workouts.count(:conditions => "state != 'destroying'")
        @processors = @user.workouts.find(:all, :conditions => { :state => "processing"})
        @recent_workouts = @user.workouts.find(:all, :order => "created_at DESC", :conditions => { :state => ["created", "uploaded"] })[0,2]        
      }
      format.js {
        render(:partial => 'common/workouts/index', :layout => false)
      }
    end
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
    Delayed::Job.enqueue(DestroyWorkoutJob.new(@workout.id))
    redirect_to(:action => 'index')
  end
  
  def edit
    render(:layout => false)
  end
  
  def update
    @workout.update_attributes(params[:workout])
    marker = @workout.markers.first
    marker.duration = params[:marker].symbolize_keys
    marker.save
  end
    
  def show
  end
  
  private
    def find_workouts
      @sort_order = params[:sort_order] || @user.preferences[:sort_order]
      order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
      @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order, :conditions => { :state => ["created", "uploaded"] })
    end
end
