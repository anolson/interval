class Shared::WorkoutsController < Shared::SharedController  
  before_filter :check_sharing
  before_filter :find_workouts, :only => [:index]
  before_filter :find_workout, :only => [:show]
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  
  def initialize
    @sharing=true
  end
  
  def index
    respond_to do |format|
      format.atom { 
        @updated = @user.workouts.last ? @user.workouts.last.created_at : Time.now.utc
        @workouts = @user.workouts.find(:all, :conditions => { :state => ["created", "uploaded"], :shared => true})
        render(:layout => false)
      }
      format.html
      format.js { render(:partial => 'common/workouts/index', :layout => false) }
    end
  end
  
  def show
    respond_to do |format|
      format.html 
    end
  end  
    
end
