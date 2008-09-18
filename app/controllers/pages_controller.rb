class PagesController < ApplicationController

  skip_before_filter :check_authentication
  def index
  end
  
  def privacy_policy
  end
  
  def plans
  end
  
  def terms
  end
end
