class Sub::ApplicationController < ApplicationController
  layout "sub"
  Footnotes::Filter.notes = []

  def faye_broadcast(channel, msg)
    message = {:channel => channel, :data => msg, :ext => {:auth_token => APP_CONFIG['faye_token']}}
    uri = URI.parse(APP_CONFIG['faye_url'])
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
  def post_faye_model(model,serializer)
    model_json = serializer.new(model)
    broadcast_json = {models: [model_json]}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
  def post_faye_models(models,serializer,model_name)
    model_json = ActiveModel::ArraySerializer.new(models, each_serializer: serializer)
    broadcast_json = {models: [{model_name.to_param => model_json}]}.to_json
    faye_broadcast "/messages/from_rails", broadcast_json
  end
end
