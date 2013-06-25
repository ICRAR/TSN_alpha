# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.alliances = new Object;


TSN.alliances.show = () ->
  id = $(document.body).data("id")

  metrics = [
    "stats.gauges.TSN_dev.general.alliance.#{id}.current_members",
    "stats.gauges.TSN_dev.general.alliance.#{id}.rank",
    "stats.gauges.TSN_dev.general.alliance.#{id}.total_credit",
    "stats.gauges.TSN_dev.general.alliance.#{id}.daily_credit",
  ]
  names = ['Current Members','Rank','Total Credit','Daily Credit']

  TSN.rickshaw_graph(metrics,names,$("#alliance_graph"),'-24months')

  $("#invite_form").bind("ajax:success", (evt, data, status, xhr) ->
    if data.success
      #replace button with success msg
      new_content = "<p class=\"text-success\">#{data.message}</p>"
    else
      #replace button with error msg
      new_content = "<p class=\"text-error\">#{data.message}</p>"
    $("#inviteBox").append(new_content)

  )

TSN.alliances.edit = () ->
  $("#alliance_tags").tokenInput "/alliances/tags.json",
    prePopulate: $("#alliance_tags").data("pre"),
    preventDuplicates: true,
    noResultsText:     "No results, needs to be created.",
    animateDropdown:   false,
    tokenValue:        'name',
    theme:             'facebook'

