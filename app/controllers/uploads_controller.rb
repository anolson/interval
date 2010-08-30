class UploadsController < ApplicationController
  layout 'standard'
  def new 
    @workout = Workout.new
  end
  
  def create
    @workout = Workout.new(params[:workout])
    @workout.user = @user
  
    if @workout.save
      @workout.process!
      WorkoutsWorker.async_process_workout(:workout_id => @workout.id)
      redirect_to(:controller => 'workouts', :action => 'index')
    else
      render(:action => 'new')
    end
  end
end