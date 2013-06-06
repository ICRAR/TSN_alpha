class NereusStatsItem < ActiveRecord::Base
  attr_accessible :credit, :daily_credit, :nereus_id, :rank, :network_limit,
                  :monthly_network_usage, :paused, :active, :online_today, :online_now,
                  :mips_now, :mips_today
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def self.connect_to_backend_db(connect_timeout = 10)
    begin
      remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host'], :username => APP_CONFIG['nereus_username'], :database => APP_CONFIG['nereus_database'], :password => APP_CONFIG['nereus_password'], :connect_timeout => connect_timeout)
    rescue
      remote_client=false
    end
  end

  #sets active status on remote server
  def set_status
    self.active = (!self.limited?  && paused == 0) ? 1 : 0
    self.save
    remote_client =  NereusStatsItem.connect_to_backend_db
    query = "UPDATE accountstatus
                          SET time = #{(Time.now.to_f*1000).to_i}, active = #{active}
                          WHERE skynetID = #{nereus_id}"
    #remote_client.query(query)
  end

  #gets account status from remote server and updates model
  def update_status
    if !last_checked_time or (last_checked_time < 1.minutes.ago)
      remote_client =  NereusStatsItem.connect_to_backend_db(1)
      if remote_client
        results = remote_client.query("SELECT skynetID, onlineNow, onlineToday, mipsNow, mipsToday, active
                              FROM accountstatus
                              WHERE skynetID = #{nereus_id}"
                            )
        if results.first != nil
          self.online_today = results.first['onlineToday']
          self.online_now = results.first['onlineNow']
          self.mips_now = results.first['mipsNow']
          self.mips_today = results.first['mipsToday']
          self.active = results.first['active']
          self.last_checked_time = Time.now
          self.save
        else
          false
        end
      else
        false
      end
    else
      false
    end
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

  def self.next_nereus_id
    n = NereusStatsItem.where("nereus_id BETWEEN 20000 AND 90000").order("nereus_id DESC").first
    n == nil ? 20000 : n.nereus_id + 1
  end
  def self.new_account
    new_item = NereusStatsItem.new(
        :credit => 0,
        :daily_credit => 0,
        :nereus_id => NereusStatsItem.next_nereus_id,
        :rank => 0,
        :network_limit => 0,
        :monthly_network_usage => 0,
        :paused => 0,
        :active => 1,
        :online_today => 0,
        :online_now => 0,
        :mips_now => 0,
        :mips_today => 0,
        :last_checked_time => Time.now
    )
    new_item.save
    return new_item
  end
end
