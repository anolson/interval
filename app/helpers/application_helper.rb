# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_item(name, path)    
    content_tag :li, link_to(name, path), :class => current_page?(path) && 'current' || nil 
  end
  
  def navigation_item_for_path(name, path, options = {})    
    content_tag :li, link_to(name, path), :class => current_controller?(options) && 'current' || nil 
  end
  
  def secondary_item(name, path)    
    content_tag :li, link_to_unless_current(name, path)
  end
  
  def link_to_unless_current_controller(name, options = {})
    link_to_unless(current_controller?(options) , name, options.reject{|k,v| k.eql?(:include)})
  end

  def current_controller?(options={})
    options[:include].detect{|c| c.eql?(controller.controller_name)}
  end
  
  
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end
  
  
  def info_box(options = {}, &block)
    block_to_partial('common/info_box', &block)
  end
  
  def rounded_box(header, wrapper_size, box_size, options = {}, &block)
    block_to_partial('common/rounded_box', 
      options.merge(:header => header, :wrapper_size => wrapper_size, :box_size => box_size), &block)
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
    h date.strftime("%b %d, %Y")
  end
  
  def nice_date_with_day_of_week(date)
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
  
end
