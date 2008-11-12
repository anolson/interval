class Admin::AdminController < ActionController::Base
  helper :application
  before_filter :check_admin_authentication
  include SslRequirement

  def check_admin_authentication
    unless session[:admin]
      redirect_to(:controller => 'admin/session', :action => 'new')
    end
  end
end
