# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.trophies = new Object;


TSN.trophies.show = () ->
  $.each($(".trophy_share_toolbox"), ->
    trophy = $(this).data()
    TSN.trophy_share($(this).attr('id'), trophy.trophyTitle, trophy.trophyUrl)
  )


