atom_feed do |feed|
  feed.title("#{@user.preferences[:display_name]}'s Shared Workouts")
  feed.updated(@workouts.first ? @workouts.first.created_at : Time.now.utc)

  for workout in @workouts
    feed.entry(workout, :url => url_for(:action => 'show', :id => workout.id, :only_path => false)) do |entry|
      entry.title(workout.name)
      entry.content(workout.notes, :type => 'html')

      entry.author do |author|
        author.name(@user.preferences[:display_name])
      end
    end
  end
end
