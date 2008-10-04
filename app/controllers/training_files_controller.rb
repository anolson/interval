class TrainingFilesController < ApplicationController
  layout 'standard'
  before_filter :find_user
  before_filter :check_within_plan_limits, :only => [:new, :create]
  
  def download
    @file=TrainingFile.find(params[:id])
    send_data(@file.payload, :filename => @file.filename, :type=>'application/octet-stream')
  end
  
  def new 
    @workout = Workout.new
  end
  
  def create
    training_file = TrainingFile.new(params[:training_file])
    @workout = Workout.new(params[:workout])
    @workout.training_files << training_file
    #workout.markers << training_file.markers
    @workout.user = @user

    if training_file.is_srm_file_type?
      options = {}
      options[:name] = training_file.powermeter_properties.comment.gsub(/^[\w]*\s/, '') if @user.preferences[:parse_srm_comment]
      options[:notes] = @workout.notes + " (SRM comment - #{training_file.powermeter_properties.comment})" if @user.preferences[:append_srm_comment_to_notes]
      @workout.auto_assign options
    end
    
    if @workout.save
      @workout.process!
      WorkoutsWorker.async_parse_workout(:workout_id => @workout.id)
      redirect_to(:controller => 'workouts', :action => 'index')
    else
      render(:action => 'new')
    end
  #rescue
  # render(:action => 'new')
  end

end
