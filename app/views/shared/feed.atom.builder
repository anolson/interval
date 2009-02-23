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
          div.div "Distance: #{format_distance(workout.markers.first.distance, :include_units => true)}", :id => "distance"
          div.div "Average Power: #{workout.markers.first.avg_power} W", :id => "average_power"
          div.div "Norm Power: #{workout.markers.first.normalized_power} W", :id => "normalized_power"
          div.div "Average Speed: #{format_speed(workout.markers.first.avg_speed, :include_units => true)}", :id => "average_speed"
          div.div "Average Heartrate: #{workout.markers.first.avg_heartrate} bpm", :id => "average_heartrate"
          div.p "Notes: #{truncate(workout.notes, 50)}", :id => "notes"
        end
      end

      entry.author do |author|
        author.name(@user.preferences[:display_name])
      end
    end
  end
end
