class SupportController < ApplicationController
  skip_before_filter :check_authentication
  
  # GET /admin/articles
  # GET /admin/articles.xml
  def index
    @articles = Article.find(:all, :conditions => {:category => "Support"})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin/articles/1
  # GET /admin/articles/1.xml
  def show
    @article = Article.find(params[:id])
    @article.update_attribute("number_of_views", @article.number_of_views + 1)
    @article.save
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end
  
end
