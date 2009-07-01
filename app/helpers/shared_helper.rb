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
    

end
