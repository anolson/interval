class SharedController < ApplicationController
  layout 'standard'
  skip_before_filter :check_authentication
  
  before_filter :check_sharing
  before_filter :find_workouts, :only => [:index, :list, :feed]
  before_filter :find_workout, :only => [:show, :graph]
  
  def initialize
    @sharing=true
  end
  
  def index
    render :action => 'list'
  end
  
  def download
    file=TrainingFile.find(params[:id])
    workout = Workout.find(file.workout)
    if workout.belongs_to_user?(@user.id)
      send_data(file.payload, :filename => file.filename, :type=>'application/octet-stream')
    end
  end
  
  def feed
    @updated = @user.workouts.last ? @user.workouts.last.created_at : Time.now.utc
    @workouts = @user.workouts.find :all, :order => 'performed_on DESC'
    respond_to do |format|
      format.atom { render :layout => false }
    end
  end
  
  def list
    render(:partial => 'common/list', :layout => false)
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
  
  private
    def check_sharing
      @user = User.find_by_username(params[:user]) or raise ActiveRecord::RecordNotFound
      if @user.preferences[:enable_sharing].eql?(false)
        render :action => 'sharing_not_enabled', :layout => 'application' 
      end
    end
    
    def find_workouts
      @sort_order = params[:sort_order] || 'name'
      order = @sort_order.eql?('name') && "#{@sort_order} ASC" || "#{@sort_order} DESC"
      @workouts = Workout.paginate_by_user_id(@user.id, :page => params[:page], :order => order)
    end
    
    def find_workout
      @workout = Workout.find(params[:id]) 
      unless @workout.belongs_to_user?(@user.id)
        redirect_to :action => 'index'
      end
    end
    
    
end
