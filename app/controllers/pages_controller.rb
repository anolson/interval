class PagesController < ApplicationController

  skip_before_filter :check_authentication
  def index
  end
  def privacy_policy
  end
end
