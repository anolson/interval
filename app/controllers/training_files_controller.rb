class TrainingFilesController < ApplicationController
  
  def download
    @file=TrainingFile.find(params[:id])
    send_data(@file.payload, :filename => @file.filename, :type=>'application/octet-stream')
  end

end
