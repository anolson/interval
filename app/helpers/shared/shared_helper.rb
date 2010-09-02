require "#{Rails.root}/app/helpers/workouts_helper.rb"

module Shared::SharedHelper
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
    link_to workout.name, shared_private_workout_path(:id => workout.id, :hash => @user.private_sharing_hash)
  end
  
  def link_to_shared_workout(workout, format=nil)
    link_to(workout.name, shared_workout_path(:id => workout.id, :user => @user.username))
  end
  
  def link_to_workout_download(file)
    if(@private)
      link_to_private_shared_workout_download(file)
    else
      link_to_shared_workout_download(file)
    end
  end
  
  def link_to_private_shared_workout_download(file)
    link_to(file.filename, shared_private_download_path(:id => file, :hash => @user.private_sharing_hash))
  end
  
  def link_to_shared_workout_download(file)
    link_to(file.filename, shared_download_path(:id => file, :user => @user.username))
  end

  def link_to_workouts()
    if(@private)
      link_to_private_shared_workouts
    else
      link_to_shared_workouts
    end
  end
  
  def link_to_private_shared_workouts
    link_to("#{content_tag(:span, '&laquo;', :class=>'huge')} Back to workouts", shared_private_workouts_path)
  end
  
  def link_to_shared_workouts
    link_to("#{content_tag(:span, '&laquo;', :class=>'huge')} Back to workouts", shared_workouts_path)
  end


end
