$(document).ready(
  jQuery ->

    faye = new Faye.Client("http://localhost:9292/faye")
    faye.subscribe "/messages/from_rails", (json_data) ->
      store = TheSkyMap.__container__.lookup('store:main')
      data = jQuery.parseJSON( json_data )
      for model in data.models
        store.pushPayload('shout_box', model)
)