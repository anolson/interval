module ActionView::Helpers::UrlHelper
  def link_to_unless_current_controller(name, options = {})
    link_to_unless(current_controller?(options) , name)
  end

  def current_controller?(options ={})
    controller.controller_name.eql?(options[:controller])
  end
end
