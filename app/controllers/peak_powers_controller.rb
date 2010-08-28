class PeakPowersController < ApplicationController
  layout 'standard'
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  def show
    respond_to do |format|
      format.html {
        @all_time_best = @user.all_time_best_peak_powers
      }
      format.json {        
        @peak_power_data_points = @workout.peak_power_data_points
        @all_time_best = @user.all_time_best_peak_powers
        render :layout => false
      }
    end
  end

end
