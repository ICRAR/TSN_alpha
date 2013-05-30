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

$(document).ready(setup_announcement)