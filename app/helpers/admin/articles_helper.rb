module Admin::ArticlesHelper
  def articles_header(articles)
    content_tag(:span, "Listing all articles (#{articles.length})", :class => "larger")
  end
  
  def edit_article_header
    content_tag(:span, "Edit article.", :class => "larger")
  end
  
  def new_article_header
    content_tag(:span, "Add a new article.", :class => "larger")
  end
end
