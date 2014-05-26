class PostToFaye
  def self.faye_broadcast(channel, msg)
    message = {:channel => channel, :data => msg, :ext => {:auth_token => APP_CONFIG['faye_token']}}
    uri = URI.parse(APP_CONFIG['faye_url'])
    Net::HTTP.post_form(uri, :message => message.to_json)
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
end

