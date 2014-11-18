# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.galaxy_mosaics = new Object;


TSN.galaxy_mosaics.show = () ->
  $.each($(".mosaic_share_toolbox"), ->
    mosaic = $(this).data()
    TSN.mosaic_share($(this).attr('id'), mosaic)
  )


