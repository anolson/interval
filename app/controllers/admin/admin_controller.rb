class Admin::AdminController < ActionController::Base
  helper :application
  before_filter :check_admin_authentication,
                :check_admin_authorization
  include SslRequirement
  helper_method :admin_logged_in?
  
  def admin_logged_in?
    true if session[:admin]
  end

  def check_admin_authentication
    unless admin_logged_in?      
      redirect_to(:controller => 'admin/session', :action => 'new')
      return false
    end
  end
  
  def check_admin_authorization
    @user = User.find(session[:admin])
    @user.roles.detect {|role| role.name == Role::ADMIN}
  end
end
