class TrainingFilesController < ApplicationController
  layout 'standard'
    
  def download
    file=TrainingFile.find(params[:id])
    workout = Workout.find(file.workout)
    if workout.belongs_to_user?(@user.id)
      send_data(file.payload, :filename => file.filename, :type=>'application/octet-stream')
    end
  end
  
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
