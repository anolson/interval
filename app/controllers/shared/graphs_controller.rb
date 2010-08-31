class Shared::GraphsController < Shared::SharedController 
  before_filter :check_sharing
  before_filter :find_workouts, :only => [:index]
  before_filter :find_workout, :only => [:show]
  before_filter :check_that_workout_belongs_to_user, :only => [:show, :edit, :update, :destroy]
  
  def show
    respond_to do |format|
      format.html 
      format.json {        
        @data_points = @workout.data_points
        render :template => 'graphs/show.json.erb', :layout => false
      }
    end
  end
  
end
