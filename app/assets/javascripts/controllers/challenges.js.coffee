# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.challenges = new Object;


TSN.challenges.new = () ->
  $('#challenge_start_date').datetimepicker
    onShow: (ct) ->
      @setOptions maxDate: (if $("#challenge_end_date").val() then $("#challenge_end_date").val() else false)

  $("#challenge_end_date").datetimepicker
    onShow: (ct) ->
      @setOptions minDate: (if $("#challenge_start_date").val() then $("#challenge_start_date").val() else false)


TSN.challenges.create = TSN.challenges.new

