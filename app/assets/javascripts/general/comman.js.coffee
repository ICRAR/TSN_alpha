this.TSN = new Object();



#******* custom alert box using bootbox
custom_alert_box = ->
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


setup_announcement = ->
  $(".announcement").each( ->
    block = $(this)
    block.children('.btn-group').children(".announcement-hide").click({parent: this}, (e)->
      $(e.data.parent).alert('close')
    )
    block.children('.btn-group').children(".announcement-view").click({parent: this}, (e)->
      id = $(e.data.parent).data('id')
      $.ajax("/news/#{id}/dismiss.json")
      $(e.data.parent).alert('close')
    )
    block.children('.btn-group').children(".announcement-dismiss").click({parent: this}, (e)->
      id = $(e.data.parent).data('id')
      $.getJSON("/news/#{id}/dismiss.json", (data) ->
        if data.new
          block.replaceWith(data.html)
          setup_announcement()
        else
          block.alert('close')
      )
    )
  )

placeholder_check = () ->
  if jQuery.support.placeholder == false
    $('[placeholder]').each (index, element) =>
      $('<label for="' + $(element).attr('id') + '">' + $(element).attr('placeholder') + '</label >').insertBefore($(element))

$(document).ready( ->
  setup_announcement()
  custom_alert_box()
  placeholder_check()
  #using bootstrap-progressbar
  $('.progress .bar').progressbar(
    display_text: 1
  )
  $('a.fancybox').fancybox()
  $('a.fancybox_image').fancybox(
    'type' : 'image'
  )
)


TSN.GRAPHITE =  {
  stats_path: (id) ->
    pad = new Array(1+9).join('0')
    padded = (pad+id).slice(-9)
    padded.match(/.{3}/g).join('.')
}