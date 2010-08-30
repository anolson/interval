# app/helpers/remote_link_renderer.rb

require 'will_paginate'

class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def page_link_or_span(page, span_class = 'current', text = nil)
    classnames=Array[*span_class]
    text ||= page.to_s
    if page and page != current_page
      @template.link_to_remote text, :url => url_for(page), :method => :get
    else
      @template.content_tag :span, text, :class => classnames.join(' ')
    end
  end
end