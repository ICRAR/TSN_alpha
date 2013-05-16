class NereusStatsItem < ActiveRecord::Base
  attr_accessible :credit, :daily_credit, :nereus_id, :rank, :network_limit,
                  :monthly_network_usage, :paused, :active, :online_today, :online_now,
                  :mips_now, :mips_today
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def self.connect_to_backend_db
    remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host'], :username => APP_CONFIG['nereus_username'], :database => APP_CONFIG['nereus_database'], :password => APP_CONFIG['nereus_password'])
  end

  def for_json
    result = Hash.new
    result[:credit] = credit
    result[:rank] = rank
    result[:network_limit] = network_limit
    result[:monthly_network_usage] = monthly_network_usage
    result[:paused] = paused
    result[:active] = active
    result[:online_today] = online_today
    result[:online_now] = online_now
    result[:mips_now] = mips_now
    result[:mips_today] = mips_today
    result[:limited] = self.limited?
    return  result
  end

  #sets active status on remote server
  def set_status
    self.active = (!self.limited?  && paused == 0) ? 1 : 0
    self.save
    remote_client =  NereusStatsItem.connect_to_backend_db
    remote_client.query("UPDATE accountstatus
                          SET time = #{(Time.now.to_f*1000).to_i}, active = #{active}
                          WHERE skynetID = #{nereus_id}"
                       )
  end

  #gets account status from remote server and updates model
  def update_status
    remote_client =  NereusStatsItem.connect_to_backend_db
    results = remote_client.query("SELECT skynetID, onlineNow, onlineToday, mipsNow, mipsToday, active
                          FROM accountstatus
                          WHERE skynetID = #{nereus_id}"
                        )
    self.online_today = results.first['onlineToday']
    self.online_now = results.first['onlineNow']
    self.mips_now = results.first['mipsNow']
    self.mips_today = results.first['mipsToday']
    self.active = results.first['active']
    self.save
  end

  #forces pausing of all open clients
  def pause_resume
    self.paused = paused == 1 ? 0 : 1
    self.set_status
  end
  def pause
    self.paused = 1
    self.set_status
  end
  def resume
    self.paused = 0
    self.set_status
  end

  def limited?
    network_limit != 0 && (monthly_network_usage > network_limit)
  end

  def network_limit_mb
    network_limit / 1024 / 1024
  end

  def monthly_network_usage_mb
    monthly_network_usage / 1024 / 1024
  end
end
