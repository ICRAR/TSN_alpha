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

  if boinc_id
    name.push("POGS Credit")
    name.push("POGS RAC")
    metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.credit")
    metrics.push("stats.gauges.TSN_dev.boinc.users.#{TSN.GRAPHITE.stats_path(boinc_id)}.rac")
  if nereus_id
    name.push("SourceFinder Credit")
    name.push("SourceFinder MIPS")
    name.push("SourceFinder RAC")
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.credit")
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.mips_now")
    metrics.push("stats.gauges.TSN_dev.nereus.users.#{TSN.GRAPHITE.stats_path(nereus_id)}.daily_credit")

  name.push("Rank")
  name.push("Total Credit")

  metrics.push("stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id)}.rank")
  metrics.push("stats.gauges.TSN_dev.general.users.#{TSN.GRAPHITE.stats_path(profile_id)}.credit")

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

  TSN.rickshaw_graph(metrics,name,$("#chart_container"),'-24months')  if name.length != 0

TSN.profiles.trophies = () ->
  #share on facebook
  $(".facebook_share_trophy").click(->
    trophy = $(this).data()
    FB.ui
      method: "feed"
      link: trophy.trophyUrl
      picture: trophy.trophyImage
      name: "I just earned #{trophy.trophyTitle} trophy on theSkynet.org for playing my part in discovering our Universe!"
      caption: "theSkyNet.org"
      description: "Want to help astronomers make awesome discoveries and understand our Universe? Then theSkyNet needs you!"
    , (response) ->
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








