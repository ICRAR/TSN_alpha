module GraphiteUrlModule
  def graph_url (target,width,height,from,title)
    APP_CONFIG['graphite_url'] + "render?from=#{from}&until=now&width=#{width}&height=#{height}&target=#{target}&title=#{title}"
  end
  def simple_graph(target)
    graph_url(target,400,250,'-24hours',target)
  end
end