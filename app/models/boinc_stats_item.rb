class BoincStatsItem < ActiveRecord::Base

  attr_accessible :boinc_id, :credit, :RAC, :rank, :as => :admin
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def for_json
    result = Hash.new
    result[:credit] = credit
    result[:RAC] = self.RAC
    result[:rank] = rank
    return  result
  end
  #using a users email and password (not hashed) looks up the account and if it exists
  # returns the corresponding boinc_stats_item or creates a new one
  def find_by_boinc_auth(email, password)
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
        statsd_batch = Statsd::Batch.new($statsd)
        statsd_batch.gauge("boinc.users.#{id}.credit",0)
        statsd_batch.gauge("boinc.users.#{id}.rac",0)
        statsd_batch.flush
      end

      if item.general_stats_item_id != nil
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
end
