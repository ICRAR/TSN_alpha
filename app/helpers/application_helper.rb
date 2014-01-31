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
  def markdown(content)
    @redcarpet_renderer ||= Redcarpet::Render::HTML.new(:filter_html => true,
                                                        :hard_wrap => true)
    @markdown ||= Redcarpet::Markdown.new(@redcarpet_renderer,
                                          no_intra_emphasis: true,
                                          tables: true,
                                          strikethrough: true,
                                          superscript: true,
                                          underline: true,
                                          quote: true,
                                          autolink: true,
                                          space_after_headers: true,
                                          fenced_code_blocks: true,
                                          disable_indented_code_blocks: true)
    @markdown.render(content).html_safe
  end
end
