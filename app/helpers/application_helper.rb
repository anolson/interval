# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_item(name, options = {})    
    content_tag :li, link_to_unless_current(name, options), :class => current_page?(options) && 'current' || nil 
  end
  
  def navigation_item_for_controller(name, options = {})    
    content_tag :li, link_to_unless_current_controller(name, options), :class => current_controller?(options) && 'current' || nil 
  end
  
  def secondary_item(name, options = {})    
    content_tag :li, link_to_unless_current(name, options)
  end
  
  def link_to_unless_current_controller(name, options = {})
    link_to_unless(current_controller?(options) , name, options)
  end

  def current_controller?(options ={})
    options[:controller].detect{|c| c.eql?(controller.controller_name)}
  end
  
  
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options), block.binding)
  end
  
  
  def info_box(options = {}, &block)
    block_to_partial('common/info_box', &block)
  end
  
  def rounded_box(header, wrapper_size, box_size, options = {}, &block)
    block_to_partial('common/rounded_box', options.merge(:header => header, :wrapper_size => wrapper_size, :box_size => box_size), &block)
  end
  
  def container(size, options = {}, &block)
    block_to_partial('common/container', options.merge(:size => size), &block)
  end
  
  def sidebar_div_tag(options = {}, &block)
    block_to_partial('common/sidebar', &block)
  end
  
  
  
  # Produces -> Thursday 25 May 2006 - 1:08 PM
  def nice_datetime(date)
    h date.strftime("%A %b %d, %Y at %l:%M %p")
  end
  
  def nice_date(date)
    h date.strftime("%A %b %d, %Y")
  end
  
  def nice_date_short(date)
    h date.strftime("%m/%d/%y")
  end
  
  def nice_time(date)
    h date.strftime("%l:%M")
  end
  
  def nice_duration(date)
    h date.strftime("%k:%M:%S")
  end
  
  def set_focus_for(id)
    javascript_tag("$('#{id}').focus()")
  end
  
  def format_speed_mph(speed)
    ((speed * 3600) / 1609344.0  ).round_with_precision(1)
  end
  
  def format_distance_in_miles(distance)
    sprintf( "%.1f", distance / 1609344.0 ) 
  end
  
  def link_to_workout(workout, format = nil)
    link_to workout.name, 
      :action => "show",  
      :id => workout.id,
      :format => format 
    end
  
end
