# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.misc = new Object;


TSN.misc.advent = () ->
  shrink = (item) ->
    item.transition({
      scale: 1.2,
      rotate: '20deg'
    },2000,() ->
      grow(item)
    )
  grow = (item) ->
    item.transition({
      scale: 0.8,
      rotate: '-20deg'
    },2000,() ->
      shrink(item)
    )
  shrink($('h3.current'))