$(document).ready(
  jQuery ->
    if (typeof Faye != "undefined" )
      window.faye = new Faye.Client("http://localhost:9292/faye")
      window.faye.subscribe "/messages/from_rails", (json_data) ->
        store = TheSkyMap.__container__.lookup('store:main')
        current_player = TheSkyMap.__container__.lookup('controller:currentPlayer')
        data = jQuery.parseJSON( json_data )
        #sends a simple alert
        if data.alert?
          alert(data.alert.msg)
        #sends a simple alert and the resets the page
        if data.request_refresh?
          alert(data.request_refresh.msg)
          location.reload(true)
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
          for model_id in model_ids
            local_model = store.getById(model_name,model_id)
            local_model.reload() unless local_model == null
        #request the ember store to update a model or load if the player id matchs
        current_player_id = parseInt(current_player.get('id'))
        if data.update_models_player_only?
          if current_player_id in data.update_models_player_only.player_ids
            for model_name, model_ids of data.update_models_player_only.models
              for model_id in model_ids
                local_model = store.getById(model_name,model_id)
                if local_model == null
                  store.find(model_name,model_id)
                else
                  local_model.reload()
        #methods for new messages or ack'd messages
        #new message
        if data.new_message?
          if current_player_id == data.new_message.player_id
            store.find('message',data.new_message.msg_id).then(() ->
              #update controller
              msg_cnt = TheSkyMap.__container__.lookup('controller:messagesIndex')
              msg_cnt.get('model').set('content',store.all('message').content)
            )
            current_player.set('unread_msg_count',data.new_message.new_count)
        if data.ack_msg?
          if current_player_id == data.ack_msg.player_id
            local_model = store.getById('message',data.ack_msg.msg_id)
            local_model.set('ack',true) unless local_model == null
            current_player.set('unread_msg_count',data.ack_msg.new_count)

    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    });
)