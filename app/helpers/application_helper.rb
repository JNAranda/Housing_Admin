module ApplicationHelper
  
  # return a title on a per-page basis.
  def title
    base_title = "My Sample_App"
    if @title.nil?
     base_title
     else
       "#{base_title} | #{@title}"
    end 
  end
  def logo
    image_tag("admin.jpg", :alt => "Sample App", :class => "round")
  end
end
