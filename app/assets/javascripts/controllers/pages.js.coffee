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
  TSN.rickshaw_graph(metrics_global,names_global,$("#global_graphs"),'-24months')


  metrics_boinc = [
    'stats.gauges.TSN_dev.boinc.stat.total_credit'
    'stats.gauges.TSN_dev.boinc.stat.active_users'
    'stats.gauges.TSN_dev.boinc.stat.total_users'
    'scale(stats.gauges.TSN_dev.boinc.stat.total_rac%2C0.000005)'
  ]
  names_boinc =  ['POGS Total Credit','POGS Active Users','POGS Total Users','POGS Current TFLOPS']
  TSN.rickshaw_graph(metrics_boinc,names_boinc,$("#boinc_graphs"),'-24months')

  metrics = [
    'stats.gauges.TSN_dev.nereus.stats.total_credit'
    'stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit'
    'stats.gauges.TSN_dev.nereus.stats.total_user'
    'scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000005)'
  ]
  names =  ['SourceFinder Total Credit','SourceFinder Active Users','SourceFinder Total Users','SourceFinder Current TFLOPS (estimate)']
  TSN.rickshaw_graph(metrics,names,$("#nereus_graphs"),'-24months')

  $('#js-news').ticker(
    titleText: I18n.t("js.stats.latest"),
    controls: false
  )

  #news slider
  news_items = []
  for item in $('#news_list .news_item')
    news_items.push item
    $(item).remove()

  news_add_item = () ->
    if $('#news_list .news_item').length > 2
      item = $('.news_item').get(-1)
      news_items.push item
      old_item = $(item)
      old_item.slideUp(2000,'easeOutQuad', () ->
        old_item.remove()
      )
    if news_items.length > 0
      $('#news_list').prepend(news_items.shift())
      new_item = $($('.news_item').get(0))
      new_item.hide()
      new_item.slideDown(2000,'easeOutQuad')
  news_timer = $.timer(news_add_item,4000, true)

  $('#news').mouseover(() ->
    news_timer.pause()
  ).mouseout(() ->
    news_timer.play()
  )

