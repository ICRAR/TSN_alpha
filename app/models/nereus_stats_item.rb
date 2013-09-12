class NereusStatsItem < ActiveRecord::Base
  attr_accessible :credit, :daily_credit, :nereus_id, :rank, :network_limit,
                  :monthly_network_usage, :paused, :active, :online_today, :online_now,
                  :mips_now, :mips_today, :last_checked_time, :report_time_sent
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def self.connect_to_backend_db(connect_timeout = 10)
    begin
      remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host'], :username => APP_CONFIG['nereus_username'], :database => APP_CONFIG['nereus_database'], :password => APP_CONFIG['nereus_password'], :connect_timeout => connect_timeout)
    rescue
      remote_client=false
    end
  end
  def credit
    self[:credit].to_i
  end
  #returns current state out of
  #  pausing: acitve and paused
  #  paused: not active and paused
  #  running: active and online_now > 0
  #  ready:   active and not paused and not online_now
  #  network_limited: not active and network_limited
  #  resuming not active and not paused
  #  unknown:
  def current_state
    if active == 1
      if paused == 1
        :pausing
      elsif online_now > 0
        :running
      else
        :ready
      end
    else
      if paused == 1
        :paused
      elsif limited?
        :network_limited
      elsif paused  == 0
        :resuming
      else
        :unknown
      end
    end
  end
  def nereus_control_details
    all = {
      :pausing =>{
        :heading => "Your contribution is currently paused.",
        :desc =>  'Click here to resume your contribution.<br />Your client(s) will continue to process for a few minutes before ceasing activity.',
        :link => 'Resume',
        :image => 'button_disable.png',
        :image_alt => 'theSkyNet is paused',
      },
      :running =>{:heading => "You are now contributing to theSkyNet.",
                  :desc =>   'Click here to pause your contribution.<br />Why not tell your friends on facebook and build an alliance?',
                  :link => 'Pause',
                  :image => 'startedbutton.png',
                  :image_alt => 'theSkyNet is now active',
      },
      :ready =>{:heading => "Start theSkyNet.",
                :desc =>  'Start contributing your computer power now!',
                :image => 'startbutton.png',
                :image_alt => 'Start theSkyNet',
      },
      :paused =>{:heading => "Your account is currently inactive.",
                 :desc =>  'You have paused your account, so you wont be processing any more data for now.<br />Click here to unpause your account.',
                 :link => 'Resume',
                 :image => 'button_disable.png',
                 :image_alt => "theSkyNet is paused",
      },
      :network_limited =>{:heading => "Your account is currently inactive.",
                          :desc =>  'You have reached your network limit, so you wont process any more data until next month.<br />If you wish to resume contributing, either increase or disable your network limit.',
                          :link => 'None',
                          :image => 'button_disable.png',
                          :image_alt => "theSkyNet is paused",
      },
      :resuming =>{:heading => "You are now contributing to theSkyNet.",
                   :desc =>  'Click here to pause your contribution.<br />Your client(s) may take a few minutes before beginning activity.<br />Why not tell your friends on facebook and build an alliance?',
                   :link => 'Pause',
                   :image => 'startedbutton.png',
                   :image_alt => 'theSkyNet is now active',
      },
      :unknown =>{:heading => "Your account is currently inactive.",
                  :desc =>  'Click here to unpause your account.',
                  :link => 'Resume',
                  :image => 'button_disable.png',
                  :image_alt => "theSkyNet is paused",
      },
    }
    all[current_state]
  end
  #sets active status on remote server
  def set_status
    self.active = (!self.limited?  && paused == 0) ? 1 : 0
    self.save
    remote_client =  NereusStatsItem.connect_to_backend_db
    query = "UPDATE accountstatus SET time = #{(Time.now.to_f*1000).to_f}, active = #{active} WHERE skynetID = #{nereus_id}"
    #remote_client.query(query)
  end

  #queues status update
  def update_status
    if !last_checked_time || (last_checked_time < 1.minutes.ago)
      NereusStatsItem.delay.update_status(id)
    end
  end

  #gets account status from remote server and updates model
  def self.update_status(id)
    nereus = NereusStatsItem.find(id)
    if !nereus.nil?
      remote_client =  NereusStatsItem.connect_to_backend_db(1)
      if remote_client
        results = remote_client.query("SELECT skynetID, onlineNow, onlineToday, mipsNow, mipsToday, active
                              FROM accountstatus
                              WHERE skynetID = #{nereus.nereus_id}"
                            )
        if results.first != nil
          nereus.online_today = results.first['onlineToday']
          nereus.online_now = results.first['onlineNow']
          nereus.mips_now = results.first['mipsNow']
          nereus.mips_today = results.first['mipsToday']
          nereus.active = results.first['active']
          nereus.last_checked_time = Time.now
          nereus.save
        end
      end
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
    (network_limit.to_i / 1024 / 1024).to_i
  end

  def monthly_network_usage_mb
    (monthly_network_usage.to_i / 1024 / 1024).to_i
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

  #***********************************
  #***********************************
  #founding Member
  #list of extra founding members
  def self.founding_ids
    [10001,10003,10006,10017,10018,10019,10020,10021,10023,10024,104351]
  end
  #first founding member
  def self.founding_first
    100010
  end
  #last founding member
  def self.founding_last
    102939
  end
  # checks if user is a founding member
  def founding?
    extra = NereusStatsItem.founding_ids
    first = NereusStatsItem.founding_first
    last = NereusStatsItem.founding_last
    ((nereus_id >= first) && (nereus_id <= last)) || (extra.include?(nereus_id))
  end
  #returns the users founding member poistion of number
  def founding_num
    extra = NereusStatsItem.founding_ids
    first = NereusStatsItem.founding_first
    last = NereusStatsItem.founding_last
    my_id = nereus_id
    NereusStatsItem.where{(((nereus_stats_items.nereus_id >= first) &
        (nereus_stats_items.nereus_id <= last)) |
        (nereus_stats_items.nereus_id.in extra)) &
        (nereus_stats_items.nereus_id <= my_id) &
        (general_stats_item_id != nil)
        }.count
  end
  #the total number of founding members according to the database
  def self.total_founding
    extra = NereusStatsItem.founding_ids
    first = NereusStatsItem.founding_first
    last = NereusStatsItem.founding_last
    my_id = [last].concat(extra).max
    NereusStatsItem.where{(((nereus_stats_items.nereus_id >= first) &
        (nereus_stats_items.nereus_id <= last)) |
        (nereus_stats_items.nereus_id.in extra)) &
        (nereus_stats_items.nereus_id <= my_id) &
        (general_stats_item_id != nil)
    }.count
  end

  def send_cert
    #check if user has already requested a report
    #within the last 5 minuets
    if self.general_stats_item.nil? || (!self.report_time_sent.nil? && self.report_time_sent > 5.minutes.ago)
      return false

    else
      self.report_time_sent = Time.now
      self.save
      NereusStatsItem.delay.send_cert(self.id)
      return true
    end

  end
  #connects to docmosis to generate a cert then emails the cert users email
  def self.send_cert(id)
    nereus_item = NereusStatsItem.find(id)

    if nereus_item.nil? || nereus_item.general_stats_item.nil?
      return false
    else
      profile = nereus_item.general_stats_item.profile
      return false if profile.nil?

      data = {
          'Name' => profile.full_name,
          'number' => nereus_item.founding_num,
          'total' => NereusStatsItem.total_founding
      }
      template = 'Founding_Members_Certificate_Template.odt'
      output_name = 'Founding Members Certificate.pdf'
      doc = Docmosis.new(
          :template => template,
          :output_name => output_name,
          :data => data,
          :email => profile.user.email
      )
      doc.email_pdf
    end
  end
end
