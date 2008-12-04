class PeakController < ApplicationController
  layout 'standard'
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  def show
    respond_to do |format|
      format.html {
        @all_time_best = @user.all_time_best_peak_powers
        @intersections = @workout.peak_powers.collect{|p| p[:value].round} & @all_time_best.collect{|p| p[:value]}
      }
      format.json {        
        @data_points = @workout.data_points
        render :layout => false
      }
    end
  end

end
