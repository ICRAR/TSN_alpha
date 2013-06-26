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


$(document).ready(->
  $('a.fancybox').fancybox()
  $('a.fancybox_image').fancybox(
    'type' : 'image'
  )
  Util.init()


  #******* custom alert box using bootbox
  $.rails.allowAction = (link) ->
    return true unless link.attr('data-confirm')
    $.rails.showConfirmDialog(link) # look bellow for implementations
    false # always stops the action since code runs asynchronously

  $.rails.handleLink = (link) ->
    if link.data("remote") isnt `undefined`
      $.rails.handleRemote link
    else $.rails.handleMethod link  if link.data("method")
    true

  $.rails.showConfirmDialog = (link) ->
    message = link.data("confirm")
    bootbox.confirm message, "Cancel", "Yes", (confirmed) ->
      if confirmed
        link.removeAttr('data-confirm')
        $.rails.handleLink(link);
  #**************************************
  #using bootstrap-progressbar
  $('.progress .bar').progressbar(
    display_text: 1
  )
)

$(document).on 'page:fetch', ->
  $('#main').fadeOut 'slow'

$(document).on 'page:restore', ->
  $('#main').fadeIn 'slow'


@GRAPHITE =  {
 stats_path: (id) ->
  pad = new Array(1+9).join('0')
  padded = (pad+id).slice(-9)
  padded.match(/.{3}/g).join('.')
}