atom_feed do |feed|
  feed.title("#{@user.preferences[:display_name]}'s Shared Workouts")
  feed.updated(@updated)

  for workout in @workouts
    url = url_for(:action => 'show', :user=> @user.username, :id => workout.id, :only_path => false)
    feed.entry(workout, :url => url, :published => workout.performed_on) do |entry|
      entry.title(workout.name)
 
      #content = <<-eos
      #  Duration: #{nice_duration workout.markers.first.duration}<br/>
      #  Average Power: #{workout.markers.first.avg_power}<br/>
      #  Norm Power: #{workout.markers.first.normalized_power}<br/>
      #  Average Speed: #{format_speed_mph(workout.markers.first.avg_speed)}<br/>
      #  Average Heartrate: #{workout.markers.first.avg_heartrate}<br/>
      #  Notes:#{workout.notes} <br/><br/>
      #eos
      entry.content :type => 'xhtml' do |xhtml|
        xhtml.div "Duration: #{nice_duration workout.markers.first.duration}"
        xhtml.div "Average Power: #{workout.markers.first.avg_power}"
        xhtml.div "Norm Power: #{workout.markers.first.normalized_power}"
        xhtml.div "Average Speed: #{format_speed_mph(workout.markers.first.avg_speed)}"
        xhtml.div "Average Heartrate: #{workout.markers.first.avg_heartrate}"
        xhtml.p "Notes: #{truncate(workout.notes, 50)}"
      end

      entry.author do |author|
        author.name(@user.preferences[:display_name])
      end
    end
  end
end
