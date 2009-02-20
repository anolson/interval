atom_feed(:root_url => url_for(:controller => 'shared', :user => @user.username, :only_path => false)) do |feed|
  feed.title("#{@user.preferences[:display_name]}'s Shared Workouts")
  feed.updated(@updated)

  for workout in @workouts
    url = url_for(:action => 'show', :user=> @user.username, :id => workout.id, :only_path => false)
    feed.entry(workout, :url => url, :published => workout.performed_on) do |entry|
      entry.title(workout.name)
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.div :id => "workout_#{workout.id}" do |div|
          div.div "Duration: #{nice_duration workout.markers.first.duration}", :id => "duration"
          div.div "Average Power: #{workout.markers.first.avg_power}", :id => "average_power"
          div.div "Norm Power: #{workout.markers.first.normalized_power}", :id => "normalized_power"
          div.div "Average Speed: #{format_speed_mph(workout.markers.first.avg_speed)}", :id => "average_speed"
          div.div "Average Heartrate: #{workout.markers.first.avg_heartrate}", :id => "average_heartrate"
          div.p "Notes: #{truncate(workout.notes, 50)}", :id => "notes"
        end
      end

      entry.author do |author|
        author.name(@user.preferences[:display_name])
      end
    end
  end
end
