module PeakPowersHelper
  def duration_in_words(duration)
    case duration
      when 1..59 then duration.to_s + " sec"
      when 60..3599 then (duration/60).to_s + " min" 
      else (duration/3600).to_s + " hour"
    end
  end

end
