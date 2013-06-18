module ApplicationHelper
  include GraphiteUrlModule

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    title = title + "<i class=\"icon-#{sort_direction == "asc" ? "arrow-up" : "arrow-down"}\"></i>" if column == sort_column
    link_to title.html_safe, params.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

end
