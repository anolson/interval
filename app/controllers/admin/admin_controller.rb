class Admin::AdminController < ActionController::Base
  helper :application
  before_filter :check_admin_authentication,
                :check_admin_authorization
  include SslRequirement

  def check_admin_authentication
    unless session[:admin]
      redirect_to(:controller => 'admin/session', :action => 'new')
      return false
    end
  end
  
  def check_admin_authorization
    @user = User.find(session[:admin])
    @user.roles.detect {|role| role.name == Role::ADMIN}
  end
end
