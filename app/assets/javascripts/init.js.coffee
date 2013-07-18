this.TSN = new Object();

Util = {
exec: (controller, action) ->
  ns = TSN
  if controller != "" and ns[controller] and typeof ns[controller][action] == "function"
    ns[controller][action]()

init: ->
  body = document.body
  controller = body.getAttribute "data-controller"
  action = body.getAttribute "data-action"

  Util.exec "common"
  Util.exec controller
  Util.exec controller, action
}


$(document).ready( Util.init)

$(document).on 'page:fetch', ->
  $('#main').fadeOut 'slow'

$(document).on 'page:restore', ->
  $('#main').fadeIn 'slow'

$(document).on 'page:change', ->
  if window._gaq?
    _gaq.push ['_trackPageview']
  else if window.pageTracker?
    pageTracker._trackPageview()

