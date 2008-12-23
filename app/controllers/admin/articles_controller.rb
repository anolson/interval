class Admin::ArticlesController < Admin::AdminController
  # GET /admin_articles
  # GET /admin_articles.xml
  layout 'admin'
  def index
    @articles = Article.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/1
  # GET /admin_articles/1.xml
  def show
    @articles = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/new
  # GET /admin_articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/1/edit
  def edit
    @articles = Article.find(params[:id])
  end

  # POST /admin_articles
  # POST /admin_articles.xml
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to(:controller => "admin/articles") }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_articles/1
  # PUT /admin_articles/1.xml
  def update
    @articles = Article.find(params[:id])

    respond_to do |format|
      if @articles.update_attributes(params[:article])
        flash[:notice] = 'Admin::Articles was successfully updated.'
        format.html { redirect_to(@articles) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @articles.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_articles/1
  # DELETE /admin_articles/1.xml
  def destroy
    @articles = Article.find(params[:id])
    @articles.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "admin/articles") }
      format.xml  { head :ok }
    end
  end
end
