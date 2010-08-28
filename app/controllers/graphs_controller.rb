class GraphsController < ApplicationController
  layout 'standard'
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  def show
    respond_to do |format|
      format.html
      format.json {        
        @data_points = @workout.data_points
        render :template => 'common/workouts/show.json.erb', :layout => false
      }
    end
  end
end
