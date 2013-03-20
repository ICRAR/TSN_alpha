# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.profiles = new Object;


TSN.profiles.show = () ->
  id = $(document.body).data("id")

  url = "http://127.0.0.1:8080/render?
from=-5days&until=now&width=400&height=250&
target=group(
stats.gauges.TSN_dev.boinc.users.3121.credit,
stats.gauges.TSN_dev.nereus.users.101032.credit,
stats.gauges.TSN_dev.general.users.2.credit
)&format=json&jsonp=?"

  request = $.getJSON(url)
    .success (data) ->
      flot_charts_example(data)

      rick_data_boinc = []
      rick_data_nerues = []
      rick_data_boinc.push {x: d[1], y: d[0]} for d in data[0]['datapoints']
      rick_data_nerues.push {x: d[1], y: d[0]} for d in data[1]['datapoints']

      rick_graph = new Rickshaw.Graph (
        element: $("#chart")[0]
        renderer: 'area'
        width: 400,
        height: 200
        series: [
          {
            name: 'Boinc'
            color: 'steelblue'
            data: rick_data_boinc
          }
          {
            name: 'Nerues'
            color: 'red'
            data: rick_data_nerues
          }
          ]
        min: 0
                                 )
      x_axis = new Rickshaw.Graph.Axis.Time( { graph: rick_graph } )
      hoverDetail = new Rickshaw.Graph.HoverDetail( {graph: rick_graph} )
      y_axis = new Rickshaw.Graph.Axis.Y (
        graph: rick_graph,
        orientation: 'left',
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: $('#y_axis')[0]
                                         )

      rick_graph.render()
      true
    .error (jqXHR, textStatus, errorThrown) ->
      alert errorThrown





flot_charts_example = (data)  ->
  points = []
  points.push [d[1]*1000,d[0]] for d in data[0]['datapoints']
  date = new Date()
  plot = $.plot "#placeholder", [ points ],
                series:
                  lines:
                    show: true
                  points:
                    show: true
                grid:
                  hoverable: true,
                  clickable: true
                xaxis:
                  minTickSize: [1, "hour"]
                  min: ((new Date()).setDate(date.getDate() - 7))
                  max: date.getTime()
                  mode: 'time'
                  timeformat: "%a"

  $("#placeholder").bind "plothover", (event, pos, item) ->
    if item
      str = "(#{(new Date(item.datapoint[0])).toDateString()},#{item.datapoint[1].toFixed(2)})"
      $("#hoverdata").text(str)
      plot.unhighlight()
      plot.highlight(item.series, item.datapoint)

