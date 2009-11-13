class TrainingFilesController < ApplicationController
  layout 'standard'
  before_filter :check_within_plan_limits, :only => [:new, :create]
  
  def download
    file=TrainingFile.find(params[:id])
    workout = Workout.find(file.workout)
    if workout.belongs_to_user?(@user.id)
      send_data(file.payload, :filename => file.filename, :type=>'application/octet-stream')
    end
  end
  
  def new 
    #@last = @user.workouts.find(:all, :order => 'performed_on').last
    @workout = Workout.new
  end
  
  def create
    
    @workout = Workout.new(params[:workout])
    @workout.training_files.first.parse_file_header
    @workout.user = @user

    options = {}
    if @user.preferences[:auto_assign_workout_name]
      options[:name] = @workout.generate_workout_name @user.preferences[:auto_assign_workout_name_by]
    end
    if @user.preferences[:append_srm_comment_to_notes]
      options[:notes] = @workout.generate_workout_comments
    end
    
    @workout.auto_assign options
  
    if @workout.save
      @workout.process!
      WorkoutsWorker.async_parse_workout(:workout_id => @workout.id)
      redirect_to(:controller => 'workouts', :action => 'index')
    else
      render(:action => 'new')
    end
    
    
    
    # @training_file = TrainingFile.create(params[:training_file])
    #  @training_file.save
    #  if(@training_file.errors.empty?)
    #    @training_file.parse_file_header
    #    @workout = Workout.new(params[:workout])
    #    @workout.training_files << @training_file
    #    @workout.user = @user
    # 
    #    options = {}
    #    if @user.preferences[:auto_assign_workout_name]
    #      options[:name] = @workout.generate_workout_name @user.preferences[:auto_assign_workout_name_by]
    #    end
    #    if @user.preferences[:append_srm_comment_to_notes]
    #      options[:notes] = @workout.generate_workout_comments
    #    end
    #    
    #    @workout.auto_assign options
    #  
    #    if @workout.save
    #      @workout.process!
    #      WorkoutsWorker.async_parse_workout(:workout_id => @workout.id)
    #      redirect_to(:controller => 'workouts', :action => 'index')
    #    else
    #      render(:action => 'new')
    #    end
    #  else
    #    render(:action => 'new')
    # end
    
  end

end
