class DownloadsController < ApplicationController
  def show
    file = TrainingFile.find(params[:id])
    if(file.workout.belongs_to_user?(@user.id))
      send_data(file.payload, :filename => file.filename, :type=>'application/octet-stream')
    end
  end
end
