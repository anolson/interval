require "#{Rails.root}/app/helpers/workouts_helper.rb"

module Shared::WorkoutsHelper
  include WorkoutsHelper
  def options_for_secondary_links()
    if @private 
      [ { :text => 'Summary', :path => shared_private_workout_path(:id => @workout.id, :hash => @user.private_sharing_hash) }, 
        { :text => 'Graph', :path => shared_private_workout_graph_path(:private_workout_id => @workout.id, :hash => @user.private_sharing_hash)  } ]
    else
      [ { :text => 'Summary', :path => shared_workout_path(:id => @workout.id, :user => @user.username) }, 
        { :text => 'Graph', :path => shared_workout_graph_path(:workout_id => @workout.id, :user => @user.username) } ]
    end
  end
  
  def link_to_workout(workout, format = nil)
    if(@private)
      link_to_private_workout(workout)
    else
      link_to_shared_workout(workout)
    end
  end
    
  def link_to_private_workout(workout, format=nil)
    link_to workout.name, 
      :hash => @user.private_sharing_hash,
      :action => "show",  
      :id => workout.id,
      :format => format
  end

  def link_to_shared_workout(workout, format=nil)
    link_to(workout.name, shared_workout_path(:id => workout.id, :user => @user.username))
  end
end
