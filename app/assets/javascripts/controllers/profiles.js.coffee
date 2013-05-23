# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.profiles = new Object;


TSN.profiles.show = () ->  profile_show_graphs()
TSN.profiles.dashboard = () ->  profile_show_graphs()

profile_show_graphs = () ->

  profile_id = $("#chart_container").data("profile_id")
  boinc_id = $("#chart_container").data("boinc_id")
  nereus_id = $("#chart_container").data("nereus_id")
  name = []
  metrics = []

  name.push("Boinc Credit") if boinc_id
  name.push("Nereus Credit") if nereus_id

  metrics.push("stats.gauges.TSN_dev.boinc.users.#{boinc_id}.credit") if boinc_id
  metrics.push("stats.gauges.TSN_dev.nereus.users.#{nereus_id}.credit") if nereus_id

  name.push("Rank")
  name.push("Total Credit")

  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id}.rank")
  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id}.credit")

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),'-12months')  if name.length != 0






