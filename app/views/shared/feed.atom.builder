atom_feed do |feed|
  feed.title("#{@user.preferences[:display_name]}'s Shared Workouts")
  feed.updated(@workouts.first ? @workouts.first.created_at : Time.now.utc)

  for workout in @workouts
    url = url_for(:action => 'show', :user=> @user.username, :id => workout.id, :only_path => false)
    feed.entry(workout, :url => url) do |entry|
      entry.title(workout.name)
       
      content = <<-eos
        Duration: #{nice_duration workout.markers.first.duration}<br/>
        Notes:#{workout.notes} <br/><br/>
      eos
      entry.content(content, :type => 'html')

      entry.author do |author|
        author.name(@user.preferences[:display_name])
      end
    end
  end
end
