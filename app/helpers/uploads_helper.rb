module UploadsHelper
  include WorkoutsHelper
  def new_upload_header
    content_tag(:span, "Upload a workout.", :class => "larger")
  end
end
