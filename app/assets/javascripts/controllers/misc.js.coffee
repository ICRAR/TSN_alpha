# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.misc = new Object;


TSN.misc.advent = () ->
  shrink = (item) ->
    item.css({ transformOrigin: '0px 0px' }).transition({
      #scale: 1.2,
      rotate: '20deg'
    },2000,() ->
      grow(item)
    )
  grow = (item) ->
    item.css({ transformOrigin: '0px 0px' }).transition({
      #scale: 0.8,
      rotate: '-10deg'
    },2000,() ->
      shrink(item)
    )
  start = (item) ->
    item.css({
      transformOrigin: '0px 0px',
      left: '10px'
    })
    shrink(item)
  start($('h3.current'))