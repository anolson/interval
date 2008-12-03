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
      if(user.roles.detect{ |r| r.name.eql?(Role::ADMIN) })
        session[:admin] = user.id
        session[:intended_params] = nil
        flash[:notice] = "admin login success"  
        redirect_to :controller => "admin/users"
      else
        raise "You are not authorized."
      end
    end
  rescue
    flash[:notice] = $!.to_s
    render :action => 'new'
  end
  
  def destroy 
    reset_session
    redirect_to ''
  end
end
