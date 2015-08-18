#!/usr/bin/env ruby
require 'httparty'
require 'json'
require 'fileutils'

def restart_and_notify(error_string)
    ENV['ENV_TSN_ERROR_RESPONSE'] = error_string
    dir =  File.dirname(__FILE__)
    call = "cd #{dir}; rake server_restart_notify:notify_admin RAILS_ENV=production"
    puts call
    system "/bin/bash -l -c '#{call}'"
end

#Check if server is up
begin
    #if ok do nothing else run take task reset
    response = HTTParty.get('http://lvh.me/ping').parsed_response
    if response['status'] != "ok"
        json_error = JSON.generate(response, quirks_mode: true)
        restart_and_notify(json_error)
    end
rescue Errno::ECONNREFUSED, Timeout::Error => e
    restart_and_notify(e.to_s)
end

