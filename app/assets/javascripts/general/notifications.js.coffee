this.Notifications = new Object();
Notifications.update = ->
  Notifications.load_all((data) ->
    for n in data['result']
      Notifications.display(n['notification'])
  )

Notifications.load_all = (load_fnc) ->
  $.get("/notifications.json", load_fnc)

Notifications.load_one = (id,load_fnc) ->
  $.get("/notifications/#{id}.json", load_fnc)

Notifications.dismiss = (id,load_fnc) ->
  $.get("/notifications/#{id}/dismiss.json", load_fnc)

Notifications.display = (note) ->
  Messenger().post
    message: note['subject']
    type: 'success'
    actions:
      more:
        label: "More"
        action: ->
          temp_msg = this
          Notifications.load_one(note['id'], (data) ->
            note = data['result']['notification']
            temp_msg.update
              message: note['body']
              actions:
                cancel:
                  label: "Dismiss"
                  action: ->
                    this.hide()
                    Notifications.dismiss(note['id'], (data) ->
                      note = data['result']['notification']
                    )
            $('.messenger-message-inner a').click( ->
              temp_msg.hide()
              Notifications.dismiss(note['id'], (data) ->
                #do nothing
              )
            )
          )
      cancel:
        label: "Dismiss"
        action: ->
          this.hide()
          Notifications.dismiss(note['id'], (data) ->
            note = data['result']['notification']
          )
    id: note["id"]
    hideAfter: 10000