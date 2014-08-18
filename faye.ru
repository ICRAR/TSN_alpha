require 'faye'
require 'yaml'
env_string = ENV['RACK_ENV']
env_string = ENV['RAILS_ENV'] if env_string.nil? || env_string == ''
env_string = 'development' if env_string.nil? || env_string == ''
root_dir = File.dirname(__FILE__)
APP_CONFIG = YAML.load_file("#{root_dir}/config/custom_config.yml")[env_string]
class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext'].nil? || message['ext']['auth_token'] != APP_CONFIG['faye_token']
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  # IMPORTANT: clear out the auth token so it is not leaked to the client
  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {}
    end
    callback.call(message)
  end
end

Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server