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
  names_boinc =  ['Boinc Total Credit','Boinc Active Users','Boinc Total Users','Boinc Current TFLOPS']
  TSN.rickshaw_graph(metrics_boinc,names_boinc,$("#boinc_graphs"),'-24months')

  metrics = [
    'stats.gauges.TSN_dev.nereus.stats.total_credit'
    'stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit'
    'stats.gauges.TSN_dev.nereus.stats.total_user'
    'scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000005)'
  ]
  names =  ['Nereus Total Credit','Nereus Active Users','Nereus Total Users','Nereus Current TFLOPS (estimate)']
  TSN.rickshaw_graph(metrics,names,$("#nereus_graphs"),'-24months')