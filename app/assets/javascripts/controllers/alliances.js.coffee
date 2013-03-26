# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.alliances = new Object;


TSN.alliances.show = () ->
  id = $(document.body).data("id")

  metrics = ["stats.gauges.TSN_dev.alliance.#{id}.credit","stats.gauges.TSN_dev.alliance.#{id}.rank"]
  names = ['Total Credit','Rank']

  TSN.rickshaw_graph(metrics,names,$("#alliance_graph"),'-7days')