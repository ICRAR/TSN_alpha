# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.profiles = new Object;


TSN.profiles.show = () ->
  profile_show_graphs(false)
  $("#credit_explain").popover()
TSN.profiles.dashboard = () ->
  profile_show_graphs(true)
  $("#credit_explain").popover()

profile_show_graphs = (all) ->
  profile_id = $("#chart_container").data("profile-id")
  boinc_id = $("#chart_container").data("boinc-id")
  nereus_id = $("#chart_container").data("nereus-id")
  name = []
  metrics = []

  if boinc_id
    name.push("POGS Credit")
    name.push("POGS RAC")
    metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.credit")
    metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.rac")
  if nereus_id
    name.push("SourceFinder Credit")
    name.push("SourceFinder MIPS") if all == true
    name.push("SourceFinder RAC")
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.credit")
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.mips_now") if all == true
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.daily_credit")

  name.push("Rank")
  name.push("Total RAC")
  name.push("Total Credit")
  total_credit_name
  total_RAC_name
  if boinc_id & nereus_id
    total_credit_name = "sumSeries(stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.credit,stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.credit)"
    total_RAC_name = "sumSeries(stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.daily_credit,stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.rac)"
  else if boinc_id
    total_credit_name = "stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.credit"
    total_RAC_name = "stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.rac"
  else if nereus_id
    total_credit_name = "stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.credit"
    total_RAC_name = "stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.daily_credit"
  else
    total_credit_name = "stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id)}.credit"
    total_RAC_name = "stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id)}.avg_daily_credit"

  metrics.push("stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id)}.rank")
  metrics.push(total_RAC_name)
  metrics.push(total_credit_name)

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),"-#{TSN.months_from_launch()}months")  if name.length != 0

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

  name.push("#{name1} POGS Credit") if boinc_id1
  name.push("#{name2} POGS Credit") if boinc_id2
  name.push("#{name1} SourceFinder Credit") if nereus_id1
  name.push("#{name2} SourceFinder Credit") if nereus_id2

  metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id1)}.credit") if boinc_id1
  metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id2)}.credit") if boinc_id2
  metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id1)}.credit") if nereus_id1
  metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id2)}.credit") if nereus_id2

  name.push("#{name1} Rank")
  name.push("#{name2} Rank")
 # name.push("#{name1} Total Credit")
 # name.push("#{name2} Total Credit")

  metrics.push("stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id1)}.rank")
  metrics.push("stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id2)}.rank")
#  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id1}.credit")
#  metrics.push("stats.gauges.TSN_dev.general.users.#{profile_id2}.credit")

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),"-#{TSN.months_from_launch()}months")  if name.length != 0

TSN.profiles.trophies = () ->
  $.each($(".trophy_share_toolbox"), ->
    trophy = $(this).data()
    TSN.trophy_share($(this).attr('id'), trophy.trophyTitle, trophy.trophyUrl)
  )


  #founding certs
  $("#founding_cert_form").bind("ajax:success", (evt, data, status, xhr) ->
    if data.success
      #replace button with success msg
      new_content = "<p class=\"text-success\">#{data.message}</p>"
      $('#founding_cert_form input[type="submit"]').attr('disabled','disabled');
    else
      #replace button with error msg
      new_content = "<p class=\"text-error\">#{data.message}</p>"
    $("#founding_cert_box").append(new_content)

  )








