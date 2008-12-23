class Admin::ArticlesController < Admin::AdminController
  layout 'admin'
  
  # GET /admin/articles
  # GET /admin/articles.xml
  def index
    @articles = Article.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin/articles/1
  # GET /admin/articles/1.xml
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /admin/articles/new
  # GET /admin/articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /admin/articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /admin/articles
  # POST /admin/articles.xml
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

  # PUT /admin/articles/1
  # PUT /admin/articles/1.xml
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @articles.update_attributes(params[:article])
        flash[:notice] = 'Admin::Articles was successfully updated.'
        format.html { redirect_to(admin_articles_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/articles/1
  # DELETE /admin/articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(admin_articles_path) }
      format.xml  { head :ok }
    end
  end
end
