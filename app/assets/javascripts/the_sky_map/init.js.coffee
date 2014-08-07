$(document).ready(
  jQuery ->
    if (typeof Faye != "undefined" )
      window.faye = new Faye.Client("http://localhost:9292/faye")
      window.faye.subscribe "/messages/from_rails", (json_data) ->
        store = TheSkyMap.__container__.lookup('store:main')
        current_player = TheSkyMap.__container__.lookup('controller:currentPlayer')
        data = jQuery.parseJSON( json_data )
        #insert or update a model in ember
        for model_name, model of data.models
          payload = {}
          payload[model_name] =  model
          store.pushPayload(model_name, payload)
        #remove a model from ember
        for model_name, model_id of data.remove_models
          local_model = store.getById(model_name,model_id)
          local_model.deleteRecord() unless local_model == null
        #request the ember store to update a model if it already exists
        for model_name, model_ids of data.update_models
          for i, model_id of model_ids
            local_model = store.getById(model_name,model_id)
            local_model.reload() unless local_model == null
        #request the ember store to update a model or load if the player id matchs
        current_player_id = parseInt(current_player.get('id'))
        if data.update_models_player_only?
          if current_player_id in data.update_models_player_only.player_ids
            for model_name, model_ids of data.update_models_player_only.models
              for i, model_id of model_ids
                local_model = store.getById(model_name,model_id)
                local_model.reload()
    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    });
)