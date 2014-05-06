$(document).ready(
  jQuery ->

    faye = new Faye.Client("http://localhost:9292/faye")
    faye.subscribe "/messages/from_rails", (json_data) ->
      store = TheSkyMap.__container__.lookup('store:main')
      data = jQuery.parseJSON( json_data )
      for model_name, model of data.models
        payload = {}
        payload[model_name] =  model
        store.pushPayload(model_name, payload)
      for model_name, model_id of data.remove_models
        local_model = store.getById(model_name,model_id)
        local_model.deleteRecord() unless local_model == null
)