require 'socket'
namespace :server_restart_notify do
  desc "Notify Admin when the server has been reset"
  task :notify_admin => :environment do
    call = "sudo service httpd restart "
    msg =  "HTTPD server has been restarted\n\n"
    msg +=  ENV['ENV_TSN_ERROR_RESPONSE']
    local_ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    msg += "Local IP: #{local_ip}"
    AdminMailer.debug(msg, "HTTPD Restart").deliver
    system "/bin/bash -l -c '" + call + "'"
  end
end