class ProcessorsController < ApplicationController
  before_filter :find_workout, :only => [:show]
  before_filter :check_that_workout_belongs_to_user, :only => [:show]
  
  def index
    @processors = @user.workouts.find(:all, :conditions => { :state => "processing"})
  end
  
  def show
    respond_to do |format|
      format.js
    end
  end
end
