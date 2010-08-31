class Shared::DownloadsController < Shared::SharedController 
  before_filter :check_sharing
  
  def show
    file=TrainingFile.find(params[:id])
    workout = Workout.find(file.workout)
    if workout.belongs_to_user?(@user.id)
      send_data(file.payload, :filename => file.filename, :type=>'application/octet-stream')
    end
  end
  
end
