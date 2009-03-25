module SummaryHelper
  include WorkoutsHelper
  def period_in_words(type, length)
    case length 
      when 0 then "This #{type}"
      when 1 then "#{length} #{type} ago"
      else        "#{length} #{type}s ago"
    end
  end

end
