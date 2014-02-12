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


  #renders a simple breadcrumb from a hash containing {name => link}
  #tag if the tag type to be used for the links default is
  def format_breadcrumbs(links)
    links_html = []
    links.each do |name,link|
      if link == ''
        links_html << h(name)
      else
        links_html << link_to(name,link)
      end
    end
    content_tag(:div, {class: 'breadcrumbs'}) do
      links_html.join(" /\ ").html_safe
    end
  end


  def form_date_range_tag(name, default_from = '', default_to = '')
    from_id = "#{name}_from"
    from_alt_id = "#{name}_from_alt"
    to_id = "#{name}_to"
    to_alt_id = "#{name}_to_alt"
    data_attr = {
        from_id: "##{from_id}",
        from_alt_id: "##{from_alt_id}",
        to_id: "##{to_id}",
        to_alt_id: "##{to_alt_id}"
    }
    content_tag(:div, {class: 'date_range_form', data: data_attr}) do
      label_tag from_alt_id.to_sym do
        (
        "#{name.titleize} from " +
        hidden_field_tag(from_id.to_sym, default_from) +
        text_field_tag(from_alt_id.to_sym, format_time_for_date_range(default_from), readonly: true, class: 'read_only_override')+
        " to " +
        hidden_field_tag(to_id.to_sym, default_to) +
        text_field_tag(to_alt_id.to_sym, format_time_for_date_range(default_to), readonly: true, class: 'read_only_override')
        ).html_safe
      end
    end
  end

  def format_time_for_date_range(str)
    if str.nil? || str == ''
      ''
    else
      t = Time.parse(str)
      t.strftime("%A, #{t.day.ordinalize} of %B, %Y")
    end
  end


end
