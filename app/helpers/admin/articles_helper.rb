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
  
  def options_for_articles_navigation
    [ { :text => 'Add an article.', :path => new_admin_article_path } ]
  end
  
  def options_for_edit_article_navigation(article)
    [ { :text => 'Preview.', :path => edit_admin_article_path(article) } ]
  end
end
