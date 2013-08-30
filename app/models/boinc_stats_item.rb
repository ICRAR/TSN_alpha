class BoincStatsItem < ActiveRecord::Base

  attr_accessible :boinc_id, :credit, :RAC, :rank, :report_count, :as => :admin
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  #using a users email and password (not hashed) looks up the account and if it exists
  # returns the corresponding boinc_stats_item or creates a new one
  def self.find_by_boinc_auth(email, password)
    item = self.new

    query = {email_addr: email, passwd_hash: Digest::MD5.hexdigest(password+email.downcase)}.to_query
    url = APP_CONFIG['boinc_url'] + "lookup_account.php?"+ query
    remote_file = open(url)
    xml = Nokogiri::XML(remote_file)

    if xml.xpath("//error").empty?
      auth = xml.at_xpath("//account_out/authenticator").text

      query = {account_key: auth}.to_query
      url = APP_CONFIG['boinc_url'] + "am_get_info.php?"+ query
      remote_file = open(url)
      xml = Nokogiri::XML(remote_file)

      id = xml.at_xpath('//id').text.to_i

      item = self.where(boinc_id: id).first
      if !item
        item = BoincStatsItem.new
        item.boinc_id = id
        item.credit = 0
        item.RAC = 0
        item.rank = 0
        item.save
        statsd_batch = Statsd::Batch.new($statsd)
        statsd_batch.gauge("boinc.users.#{id}.credit",0)
        statsd_batch.gauge("boinc.users.#{id}.rac",0)
        statsd_batch.flush
      end

      if item.general_stats_item_id == nil
        return item
      else
        item.errors.add :base, 'That account has already been linked'
        return item
      end
    else
      #ToDo   Add error to boinc user auth
      item.errors.add :base, 'invalid account details'
      return item
    end

  end

  #Creates a new boinc account
  def self.create_new_account(email, password)

    item = self.new

    #create new boinc account
    query = {email_addr: email, passwd_hash: Digest::MD5.hexdigest(password+email.downcase), user_name: email}.to_query
    url = APP_CONFIG['boinc_url'] + "create_account.php?"+ query
    remote_file = open(url)
    xml = Nokogiri::XML(remote_file)


    if xml.xpath("//error").empty?
      auth = xml.at_xpath("//account_out/authenticator").text

      query = {account_key: auth}.to_query
      url = APP_CONFIG['boinc_url'] + "am_get_info.php?"+ query
      remote_file = open(url)
      xml = Nokogiri::XML(remote_file)

      id = xml.at_xpath('//id').text.to_i

      item = self.where(boinc_id: id).first
      if !item
        item = BoincStatsItem.new
        item.boinc_id = id
        item.credit = 0
        item.RAC = 0
        item.rank = 0
        item.save
      end

      if item.general_stats_item_id != nil
        return item
      else
        item.errors.add :base, 'That account has already been linked'
        return item
      end
    else
      #ToDo add error to boinc user auth
      item.errors.add :base, 'invalid account details'
      return item
    end

  end

  def get_report_count
    self.report_count ||= 0
    self.report_count
  end
  def inc_report_count
    self.report_count ||= 0
    self.report_count += 1
    self.save
  end

  def dec_report_count
    self.report_count ||= 0
    self.report_count -= 1
    self.report_count = 0 if report_count < 0
    self.save
  end

  def get_name_and_email
    return_hash = {}
    if general_stats_item_id.nil?
      #we need to get the stats from the boinc DB
      remote_item = BoincRemoteUser.find(boinc_id)
      return_hash[:name] = remote_item.name
      return_hash[:email] = remote_item.email_addr
    else
      profile = general_stats_item.profile
      return_hash[:name] = profile.name
      return_hash[:email] = profile.user.email
    end
    return_hash
  end

  #returns the lowest boinc_id that hasn't been connected or the highest recored boinc_id
  def self.next_id
    i = BoincStatsItem.where{general_stats_item_id == nil}.minimum(:boinc_id)
    i ||= BoincStatsItem.maximum(:boinc_id)
  end

end
