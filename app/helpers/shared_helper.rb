module SharedHelper
  include WorkoutsHelper
  
  
  def options_for_secondary_links()
    if @private 
      [ { :text => 'Summary', :options => {:action => 'show', :id => @workout.id, :hash => @user.private_sharing_hash } }, 
        { :text => 'Graph', :options => {:action => 'graph', :id => @workout.id, :hash => @user.private_sharing_hash } } ]
    else
      [ { :text => 'Summary', :options => {:action => 'show', :id => @workout.id, :user => @user.username } }, 
        { :text => 'Graph', :options => {:action => 'graph', :id => @workout.id, :user => @user.username } } ]
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
    link_to workout.name, 
      :user => workout.user.username,
      :action => "show",  
      :id => workout.id,
      :format => format
  end

end
