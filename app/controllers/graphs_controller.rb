class GraphsController < ApplicationController
  layout 'standard'
  before_filter :find_workout, :only => [:show]
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  def show
    @editable = true 
    respond_to do |format|
      format.html
      format.json {        
        @data_points = @workout.data_points
        render :layout => false
      }
    end
  end
end
