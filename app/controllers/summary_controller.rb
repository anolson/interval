require 'power_calculator.rb'

class SummaryController < ApplicationController
  layout 'standard'
  def show
    weekly
    monthly
  end
  
  private
    WEEK = 'Week'
    WEEKS = 2 
    MONTH = 'Month'
    MONTHS = 2
    
    def weekly
      @weekly = Array.new
      WEEKS.times do |i|
        @weekly << week(i) 
      end
    end
    
    def week(start) 
      today = Date.today
      week_start = today.beginning_of_week - (7 * start)
      week_end = week_start + 7
      summary_for_period((week_start..week_end), start, WEEK)
    end
    
    def monthly 
      @monthly = Array.new
      MONTHS.times do |i|
        @monthly << month(i) 
      end
    end
    
    def month(start)
      today = Date.today
      month_start = today.months_ago(start).beginning_of_month
      month_end = today.months_ago(start).end_of_month
      summary_for_period((month_start..month_end), start, MONTH)
    end
    
    def summary_for_period(range, period, type)
      workouts = Workout.find_by_date_range(range, session[:user])
      
      { :period => period,
        :type => type,
        :duration => Time.at(PowerCalculator::total(workouts.collect {|workout| workout.markers.first.duration.to_i unless workout.processing?}) || 0).utc,
        :distance => PowerCalculator::total(workouts.collect {|workout| workout.markers.first.distance unless workout.processing?}) || 0.0,
        :energy => PowerCalculator::total(workouts.collect {|workout| workout.markers.first.energy unless workout.processing?}) || 0 }
    end
  
end
