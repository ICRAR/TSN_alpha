module ApplicationHelper
  include GraphiteUrlModule
  def my_meta(hsh = {})
    title = "theSkyNet: #{hsh[:title]}"
    desc =  hsh[:description] + "\n Want to help astronomers make awesome discoveries and understand our Universe? Then theSkyNet needs you!"
    meta :title => title,
         :description => desc
    meta [:content => title, :itemprop => "name"]
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

  def logo_class_style
    unless @special_days.nil? || @special_days.first_logo.nil?
      "background:url('#{@special_days.first_logo}') 0 0 no-repeat;"
    end
  end

  #not all javascript engines support rails time formats so to increase compatibility to convert them to a ms time format instead
  def time_to_js(time)
    time.utc.to_i * 1000
  end

end
