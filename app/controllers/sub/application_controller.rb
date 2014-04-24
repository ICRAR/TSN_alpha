class Sub::ApplicationController < ApplicationController
  layout "sub"
  Footnotes::Filter.notes = []

  def faye_broadcast(channel, msg)
    message = {:channel => channel, :data => msg, :ext => {:auth_token => APP_CONFIG['faye_token']}}
    uri = URI.parse(APP_CONFIG['faye_url'])
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
