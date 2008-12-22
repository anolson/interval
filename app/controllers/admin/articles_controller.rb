class Admin::ArticlesController < ApplicationController
  # GET /admin_articles
  # GET /admin_articles.xml
  def index
    @articles = Articles.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/1
  # GET /admin_articles/1.xml
  def show
    @articles = Admin::Articles.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/new
  # GET /admin_articles/new.xml
  def new
    @articles = Admin::Articles.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /admin_articles/1/edit
  def edit
    @articles = Admin::Articles.find(params[:id])
  end

  # POST /admin_articles
  # POST /admin_articles.xml
  def create
    @articles = Admin::Articles.new(params[:articles])

    respond_to do |format|
      if @articles.save
        flash[:notice] = 'Admin::Articles was successfully created.'
        format.html { redirect_to(@articles) }
        format.xml  { render :xml => @articles, :status => :created, :location => @articles }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @articles.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_articles/1
  # PUT /admin_articles/1.xml
  def update
    @articles = Admin::Articles.find(params[:id])

    respond_to do |format|
      if @articles.update_attributes(params[:articles])
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
    @articles = Admin::Articles.find(params[:id])
    @articles.destroy

    respond_to do |format|
      format.html { redirect_to(admin_articles_url) }
      format.xml  { head :ok }
    end
  end
end
