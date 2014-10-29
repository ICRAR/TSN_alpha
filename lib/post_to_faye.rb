class PostToFaye
  def self.faye_broadcast(channel, msg)
    begin
      message = {:channel => channel, :data => msg, :ext => {:auth_token => APP_CONFIG['faye_token']}}
      uri = URI.parse(APP_CONFIG['faye_url'])
      Net::HTTP.post_form(uri, :message => message.to_json)
    rescue  Errno::ECONNREFUSED
    end
  end

  #general methods
  #sends an alert to all open connections
  def self.alert(msg)
    broadcast_json = {alert: {msg: msg}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
  #request the user to refresh their browser window
  def self.request_refresh(msg = "Apologies for the inconvenience but the browser window needs to refresh. Click Ok when you are ready.")
    broadcast_json = {request_refresh: {msg: msg}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
end
  #post new or updated models
  def self.post_faye_model_delay(model,serializer)
    PostToFaye.delay.post_faye_model_delayed(model.id,model.class.to_s, serializer.to_s)
  end
  def self.post_faye_model_delayed(model_id,model_class, serializer_s)
    model = model_class.constantize.find(model_id)
    PostToFaye.post_faye_model(model,serializer_s.constantize)
  end

  def self.post_faye_model(model,serializer)
    model_json = serializer.new(model)
    broadcast_json = {models: model_json}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
  def self.post_faye_models(models,serializer,model_name)
    model_json = ActiveModel::ArraySerializer.new(models, each_serializer: serializer)
    broadcast_json = {models: {model_name.to_param => model_json}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end

  #post to remove model
  def self.remove_model_delay(model)
    PostToFaye.delay.remove_model_delayed(model.id,model.ember_name)
  end
  def self.remove_model_delayed(model_id,model_name)
    broadcast_json = {remove_models: {model_name => model_id}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end

  #post to tell remote browser to update model if needed
  def self.request_update(model_name,model_ids)
    broadcast_json = {update_models: {model_name => model_ids}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
  #post to tell remote browser to update a model or load if the player id matchs
  def self.request_update_player_only(model_name,model_ids,player_ids)
    broadcast_json = {
        update_models_player_only: {
          models: {
              model_name => model_ids
          },
          player_ids: player_ids
        }
    }.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end

  #update messages
  #new_msg
  def self.new_msg(player_id,msg_id,new_count)
    broadcast_json = {new_message: {player_id: player_id, msg_id: msg_id, new_count: new_count}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
  #ack_msg
  def self.ack_msg(player_id,msg_id,new_count)
    broadcast_json = {ack_msg: {player_id: player_id, msg_id: msg_id, new_count: new_count}}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
end

