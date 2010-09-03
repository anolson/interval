module Admin::UsersHelper
  def edit_user_header
    content_tag(:span, "Edit user.", :class => "larger")
  end
  def users_header
    content_tag(:span, "Listing all users (#{@users.length})", :class => "larger")
  end
  
end
