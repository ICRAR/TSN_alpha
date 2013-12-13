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

  def logo_class
    out = nil
    out ||= "arr_logo" if locale == :arr
    out ||= "bat_logo" if params[:bat] == 'true' || (Time.now.day >= 30 && Time.now.month == 10) || (Time.now.day == 1 && Time.now.month == 11)
    out ||= "snow_logo" if params[:snow] == 'true' || ((Time.now > Time.parse('24th dec, 2013')) && (Time.now < Time.parse('31th dec, 2013')))
    out ||= "new_years_2013_logo" if params[:new_years_2013] == 'true' || ((Time.now > Time.parse('31th dec, 2013')) && (Time.now < Time.parse('2nd jan, 2014')))
    return out
  end

end
