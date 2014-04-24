$(document).ready(
  jQuery ->

    faye = new Faye.Client("http://localhost:9292/faye")
    faye.subscribe "/messages/new/model", (data) ->
      store = TheSkyMap.__container__.lookup('store:main')
      store.pushPayload('shout_box', jQuery.parseJSON( data ))
)