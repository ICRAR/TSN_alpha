# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.profiles = new Object;


TSN.profiles.show = () ->  profile_show_graphs()
TSN.profiles.dashboard = () ->  profile_show_graphs()

profile_show_graphs = () ->
  profile_id = $("#chart_container").data("profile-id")
  boinc_id = $("#chart_container").data("boinc-id")
  nereus_id = $("#chart_container").data("nereus-id")
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

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),'-24months')  if name.length != 0

TSN.profiles.compare = () ->
  profile_id1 = $("#chart_container").data("profile-id1")
  profile_id2 = $("#chart_container").data("profile-id2")
  boinc_id1 = $("#chart_container").data("boinc-id1")
  boinc_id2 = $("#chart_container").data("boinc-id2")
  nereus_id1 = $("#chart_container").data("nereus-id1")
  nereus_id2 = $("#chart_container").data("nereus-id2")
  name1 = $("#chart_container").data("name1")
  name2 = $("#chart_container").data("name2")
  name = []
  metrics = []

  name.push("#{name1} Boinc Credit") if boinc_id1
  name.push("#{name2} Boinc Credit") if boinc_id2
  name.push("#{name1} Nereus Credit") if nereus_id1
  name.push("#{name2} Nereus Credit") if nereus_id2

  metrics.push("stats.gauges.TSN_dev.boinc.users.#{boinc_id1}.credit") if boinc_id1
  metrics.push("stats.gauges.TSN_dev.boinc.users.#{boinc_id2}.credit") if boinc_id2
  metrics.push("stats.gauges.TSN_dev.nereus.users.#{nereus_id1}.credit") if nereus_id1
  metrics.push("stats.gauges.TSN_dev.nereus.users.#{nereus_id2}.credit") if nereus_id2

  name.push("#{name1} Rank")
  name.push("#{name2} Rank")
  name.push("#{name1} Total Credit")
  name.push("#{name2} Total Credit")

  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id1}.rank")
  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id2}.rank")
  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id1}.credit")
  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id2}.credit")

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),'-24months')  if name.length != 0




