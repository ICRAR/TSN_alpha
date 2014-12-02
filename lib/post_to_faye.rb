class PostToFaye
  def self.faye_broadcast(channel, msg)
    begin
      message = {:channel => channel, :data => msg, :ext => {:auth_token => APP_CONFIG['faye_token']}}
      url = "#{APP_CONFIG['faye_protocol']}://#{APP_CONFIG['faye_host']}:#{APP_CONFIG['faye_port']}/faye"
      HTTParty.post(url,{body: {message: message.to_json}})
    rescue  Errno::ECONNREFUSED
    end
  end

  #general methods
  #sends an alert to all open connections
  def self.alert(msg,channel_id)
    broadcast_json = {alert: {msg: msg}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  #request the user to refresh their browser window
  def self.request_refresh(channel_id,msg = "Apologies for the inconvenience but the browser window needs to refresh. Click Ok when you are ready.")
    broadcast_json = {request_refresh: {msg: msg}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  #post new or updated models
  def self.post_faye_model_delay(model,serializer,channel_id)
    PostToFaye.delay.post_faye_model_delayed(model.id,model.class.to_s, serializer.to_s,channel_id)
  end
  def self.post_faye_model_delayed(model_id,model_class, serializer_s,channel_id)
    model = model_class.constantize.find(model_id)
    PostToFaye.post_faye_model(model,serializer_s.constantize,channel_id)
  end

  def self.post_faye_model(model,serializer,channel_id)
    model_json = serializer.new(model)
    broadcast_json = {models: model_json}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  def self.post_faye_models(models,serializer,model_name,channel_id)
    model_json = ActiveModel::ArraySerializer.new(models, each_serializer: serializer)
    broadcast_json = {models: {model_name.to_param => model_json}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end

  #post to remove model
  def self.remove_model_delay(model,channel_id)
    PostToFaye.delay.remove_model_delayed(model.id,model.ember_name,channel_id)
  end
  def self.remove_model_delayed(model_id,model_name,channel_id)
    broadcast_json = {remove_models: {model_name => model_id}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end

  #post to tell remote browser to update model if needed
  def self.request_update(model_name,model_ids,channel_id)
    broadcast_json = {update_models: {model_name => model_ids}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  #post to tell remote browser to update a model or load if the player id matchs
  def self.request_update_player_only(model_name,model_ids,player_ids,channel_id)
    broadcast_json = {
        update_models_player_only: {
          models: {
              model_name => model_ids
          },
          player_ids: player_ids
        }
    }.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end

  #update messages
  #new_msg
  def self.new_msg(player_id,msg_id,new_count,channel_id)
    broadcast_json = {new_message: {player_id: player_id, msg_id: msg_id, new_count: new_count}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  #ack_msg
  def self.ack_msg(player_id,msg_id,new_count,channel_id)
    broadcast_json = {ack_msg: {player_id: player_id, msg_id: msg_id, new_count: new_count}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
  def self.ack_all_msgs(player_id,channel_id)
    broadcast_json = {ack_all_msgs: {player_id: player_id}}.to_json
    faye_broadcast "/messages/from_rails/#{channel_id}", broadcast_json
  end
end

