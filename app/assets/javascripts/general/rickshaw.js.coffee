#renders a graphite graph using the rickshaw and the following options
# metrics: an array of graphite metrics
# names:   an array of names for the legand
# div:     the jquery object for the div placeholder
# time:    the graphite timeframe for the graph
# colors   (optional) an array or colors to be used if none are specfied default colors are used
#
# eg:
#  name = ['Boinc','Nerues']
#  color = ['green','blue']
#  metrics = ['stats.gauges.TSN_dev.boinc.users.3121.credit','stats.gauges.TSN_dev.nereus.users.101032.credit']
#  rickshaw_graph(metrics,name,$("#chart"),'-5days',color)
#
TSN.rickshaw_graph = (metrics,names,div,time,colors = '') ->
  url = "http://127.0.0.1:8080/render?from=#{time}&until=now&target=group("
  url += metrics.join(',')
  url +=")&format=json&jsonp=?"
  div.css('position', 'relative')
  div.append('<div id="y_axis"></div>')
  div.append('<div id="legend"></div>')
  div.append('<div id="chart"></div>')

  rick_graph = new Rickshaw.Graph.JSONP (
    element: div.find("#chart")[0]
    renderer: 'line'
    width: 600,
    height: 200
    dataURL: url
    onData: (metrics) ->
      remote_data = []
      i = 0
      colors = new Rickshaw.Color.Palette( { scheme: 'colorwheel' } ).scheme if !colors

      for meteric in metrics
        remote_data.push []
        remote_data[i].data = []
        remote_data[i].data.push {x: d[1], y: d[0]} for d in meteric['datapoints']
        remote_data[i].name = names[i]
        remote_data[i].color = colors[i % colors.length]
        i++
      return remote_data
    onComplete: (transport) ->
      graph = transport.graph;
      detail = new Rickshaw.Graph.HoverDetail({ graph: graph })
      x_axis = new Rickshaw.Graph.Axis.Time( { graph: graph } )
      x_axis.graph.update()
      y_axis = new Rickshaw.Graph.Axis.Y (
        graph: graph,
        orientation: 'left',
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: div.find('#y_axis')[0]
                                         )
      y_axis.graph.update()
      legend = new Rickshaw.Graph.Legend(
        graph: graph,
        element: div.find('#legend')[0]
      )
      shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
        graph: graph,
        legend: legend
      )
      highlighter = new Rickshaw.Graph.Behavior.Series.Highlight(
        graph: graph,
        legend: legend
      )
      ticksTreatment = 'glow'
      order = new Rickshaw.Graph.Behavior.Series.Order(
        graph: graph,
        legend: legend
      )
    min: 'auto'
    )
