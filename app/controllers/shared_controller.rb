class SharedController < ApplicationController
  layout 'standard'
  skip_before_filter :check_authentication
  
  before_filter :check_sharing
  before_filter :find_workouts, :only => [:index, :list]
  before_filter :find_workout, :only => [:show, :graph]
  
  def initialize
    @sharing=true
  end
  
  def index
    render :template => 'workouts/index'
  end
  
  def list
    render(:partial => 'workouts/list', :layout => false)
  end
  
  def show
    respond_to do |format|
      format.html {
        render :template => 'workouts/show'
      }
      format.json {        
        range_start = params[:begin].nil? && 0 || params[:begin].to_i
        range_end = params[:end].nil? && 0 || params[:end].to_i
        @smoothed_values=@workout.smoothed_data((range_start..range_end))
        render :template=> 'workouts/show.json.erb', :layout => false
      }
    end
  end
  
  def graph
    render(:template => 'workouts/graph')
  end
  
  private
    def check_sharing
      @user = User.find_by_username(params[:user])
      if @user.preferences['enable_sharing'].eql?(false)
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
