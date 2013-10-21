# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.pages = new Object;


TSN.pages.index = () ->
  metrics_global = [
    'sumSeries(stats.gauges.TSN_dev.boinc.stat.total_credit','stats.gauges.TSN_dev.nereus.stats.total_credit)'
    'sumSeries(stats.gauges.TSN_dev.boinc.stat.active_users','stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit)'
    'sumSeries(stats.gauges.TSN_dev.boinc.stat.total_users','stats.gauges.TSN_dev.nereus.stats.total_user)'
    'sumSeries(scale(stats.gauges.TSN_dev.boinc.stat.total_rac%2C0.000005)','scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000005))'
  ]
  names_global =  ['Total Credit','Active Users','Total Users','Current TFLOPS']
  TSN.rickshaw_graph(metrics_global,names_global,$("#global_graphs"),"-#{TSN.months_from_launch()}months")


  metrics_boinc = [
    'stats.gauges.TSN_dev.boinc.stat.total_credit'
    'stats.gauges.TSN_dev.boinc.stat.active_users'
    'stats.gauges.TSN_dev.boinc.stat.total_users'
    'scale(stats.gauges.TSN_dev.boinc.stat.total_rac%2C0.000005)'
  ]
  names_boinc =  ['POGS Total Credit','POGS Active Users','POGS Total Users','POGS Current TFLOPS']
  TSN.rickshaw_graph(metrics_boinc,names_boinc,$("#boinc_graphs"),"-#{TSN.months_from_launch()}months")

  metrics = [
    'stats.gauges.TSN_dev.nereus.stats.total_credit'
    'stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit'
    'stats.gauges.TSN_dev.nereus.stats.total_user'
    'scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000005)'
  ]
  names =  ['SourceFinder Total Credit','SourceFinder Active Users','SourceFinder Total Users','SourceFinder Current TFLOPS (estimate)']
  TSN.rickshaw_graph(metrics,names,$("#nereus_graphs"),"-#{TSN.months_from_launch()}months")
  ###
  $('#js-news').ticker(
    titleText: I18n.t("js.stats.latest"),
    controls: false
  )
  ###

  #news slider
  news_items = []
  for item in $('#news_list .news_item')
    news_items.push item
    $(item).remove()

  news_add_item = () ->
    if $('#news_list .news_item').length > 3
      item = $('.news_item').get(0)
      news_items.push item
      old_item = $(item)
      old_item.slideUp(2000,'easeOutQuad', () ->
        old_item.remove()
      )
    if news_items.length > 0
      $('#news_list').append(news_items.shift())
      new_item = $('.news_item').last()
      new_item.hide()
      new_item.slideDown(2000,'easeOutQuad')
  news_timer = $.timer(news_add_item,4000, true)

  $('#news').mouseover(() ->
    news_timer.pause()
  ).mouseout(() ->
    news_timer.play()
  )
  TSN.activity_update = (restart_fn) ->
    test = restart_fn
    unless TSN.activity_pause
      $("#activity_feed #loading").show()
      TSN.activity_items = []
      $.getScript("/stats/activities?page=#{TSN.activity_item_page+1}", ->
        list = $("#activity_list")
        list.empty()
        while TSN.activity_items.length > 0
          list.prepend(TSN.activity_items.shift())
        restart_fn()
        $("#activity_feed #loading").hide()
      )
    else
      restart_fn()
  #activity feed
  $(document).ready( ->
    $("#activity_feed #loading").hide()
    $("#activity_list").liScroll({travelocity: 0.07}, TSN.activity_update)
    TSN.activity_items = []
    TSN.activity_item_page = 1
    TSN.activity_pause = false
  )

TSN.pages.show = () ->
  $("#download_pop_up strong").each(() ->
    $(this).text(window.rails.nereus_id) if $(this).text() == "nereus_id"
  )

  $('#installer_windows_32').click( ->
    url = "http://tsn.production.public.s3.amazonaws.com/sourcefinder/theSkyNet_Install_32-0.2.exe"
    download_popup(url)
    false
  )
  $('#installer_windows_32_silent').click( ->
    url = "http://tsn.production.public.s3.amazonaws.com/sourcefinder/theSkyNet_Install_32_Silent-0.2.exe"
    download_popup(url)
    false
  )
  $('#installer_windows_64').click( ->
    url = "http://tsn.production.public.s3.amazonaws.com/sourcefinder/theSkyNet_Install_64-0.2.exe"
    download_popup(url)
    false
  )
  $('#installer_windows_64_silent').click( ->
    url = "http://tsn.production.public.s3.amazonaws.com/sourcefinder/theSkyNet_Install_64_Silent-0.2.exe"
    download_popup(url)
    false
  )
  $('#installer_mac').click( ->
    url = "http://tsn.production.public.s3.amazonaws.com/sourcefinder/theSkyNet_Install_Mac.zip"
    download_popup(url)
    false
  )

download_popup = (url) ->
  text = $("#download_pop_up").html() + '<div style="text-align:center"><a href="'+ url + '" class="btn btn-success"> Download</a><a href="#" class="btn btn-tsn">Close</a></div>'
  bootbox.dialog text
  $(".modal-body a").click( ->
   bootbox.hideAll()
  )