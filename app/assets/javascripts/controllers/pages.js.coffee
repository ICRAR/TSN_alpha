# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.pages = new Object;


TSN.pages.index = () ->
  metrics = [
    'stats.gauges.TSN_dev.boinc.stat.total_credit'
    'stats.gauges.TSN_dev.boinc.stat.active_users'
    'stats.gauges.TSN_dev.boinc.stat.total_users'
    'scale(stats.gauges.TSN_dev.boinc.stat.total_rac%2C0.000005)'
  ]
  names =  ['Boinc Total Credit','Boinc Active Users','Boinc Total Users','Boinc Current TFLOPS']
  TSN.rickshaw_graph(metrics,names,$("#boinc_graphs"),'-7days')

  metrics = [
    'stats.gauges.TSN_dev.nereus.stats.total_credit'
    'stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit'
    'stats.gauges.TSN_dev.nereus.stats.total_user'
    'scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000125)'
  ]
  names =  ['Nereus Total Credit','Nereus Active Users','Nereus Total Users','Nereus Current TFLOPS (estimate)']
  TSN.rickshaw_graph(metrics,names,$("#nereus_graphs"),'-4days')