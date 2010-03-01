class Admin::UsersController < Admin::AdminController
  layout 'admin'
  # GET /admin_users
  # GET /admin_users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_users }
    end
  end

  # GET /admin_users/1
  # GET /admin_users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin_users/new
  # GET /admin_users/new.xml
  def new
    @users = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin_users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /admin_users
  # POST /admin_users.xml
  def create
    @users = User.new(params[:users])

    respond_to do |format|
      if @users.save
        flash[:notice] = 'Admin::Users was successfully created.'
        format.html { redirect_to(@users) }
        format.xml  { render :xml => @users, :status => :created, :location => @users }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @users.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_users/1
  # PUT /admin_users/1.xml
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Admin::Users was successfully updated.'
        format.html { redirect_to(:action => "edit", :id => @user.id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @users.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_users/1
  # DELETE /admin_users/1.xml
  def destroy
    @users = User.find(params[:id])
    @users.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
