module ApplicationHelper
  include GraphiteUrlModule
  def my_meta(hsh = {})
    title = "theSkyNet: #{hsh[:title]}"
    desc =  hsh[:description] + "\n Want to help astronomers make awesome discoveries and understand our Universe? Then theSkyNet needs you!"
    meta :title => title,
         :description => desc
    meta [:itemprop => "name", :content => title]
    meta [:itemprop => "description", :content => desc]

  end
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    title = title + "<i class=\"icon-#{sort_direction == "asc" ? "arrow-up" : "arrow-down"}\"></i>" if column == sort_column
    link_to title.html_safe, params.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  def form_get_hidden_tag(url)
    output = ''
    get_params =  CGI.parse(URI.parse(url).query)
    get_params.each do |key,value|
      output += hidden_field_tag key, value
    end
    output.html_safe
  end

end
