class Admin::SessionController < Admin::AdminController
  layout 'admin'
  skip_before_filter :check_admin_authentication, :check_admin_authorization
  ssl_required :new, :create
  
  def new
    @user = User.new
  end
  
  def create
    if request.post?
      user = User.authenticate(params[:user][:username], params[:user ][:password])
      session[:admin] = user.id
      session[:display_name] = user.preferences[:display_name]
      flash[:notice] = "admin login success"  
      redirect_to :controller => "admin/users"
      session[:intended_params] = nil
    end
  rescue
    flash[:notice] = $!.to_s
  end
  
  def destroy 
    reset_session
    redirect_to ''
  end
end
